require 'exception_notification/rails'
require 'exception_notification/sidekiq'

ExceptionNotification.configure do |config|
  config.ignored_exceptions += %w(
    ActionController::InvalidAuthenticityToken
    ActionController::BadRequest
    ActionController::UnknownFormat
    ActionController::ParameterMissing
    ActiveRecord::RecordNotUnique
    Mastodon::UnexpectedResponseError
    Mastodon::RaceConditionError
    Mastodon::HostValidationError
  )

  network_exceptions = %w[
    HTTP::StateError
    HTTP::TimeoutError
    HTTP::ConnectionError
    HTTP::Redirector::TooManyRedirectsError
    HTTP::Redirector::EndlessRedirectError
    OpenSSL::SSL::SSLError
    Stoplight::Error::RedLight
  ].freeze

  def handle_sidekiq(exception_name, sidekiq, network_exceptions)
    worker_class = sidekiq.dig(:job, 'class')

    network_workers = %w[
      LinkCrawlWorker
      ProcessingWorker
      ThreadResolveWorker
      NotificationWorker
      Import::RelationshipWorker
    ].freeze

    ignore_worker_errors = {
      'ActivityPub::ProcessingWorker' => ['ActiveRecord::RecordInvalid'],
      'LinkCrawlWorker' => ['ActiveRecord::RecordInvalid'],
    }.freeze

    ignore_job_errors = {
      'ActionMailer::DeliveryJob' => ['ActiveJob::DeserializationError']
    }.freeze

    return true if ignore_worker_errors[worker_class]&.include?(exception_name)

    # ActivityPub or Pubsubhubbub or 通信が頻繁に発生するWorkerではネットワーク系の例外を無視
    if worker_class.start_with?('ActivityPub::') || worker_class.start_with?('Pubsubhubbub::') || network_workers.include?(worker_class)
      return true if network_exceptions.include?(exception_name)
    end

    # ActiveJob
    if worker_class == 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper'
      return true if ignore_job_errors[sidekiq.dig(:job, 'wrapped')]&.include?(exception_name)
    end

    false
  end

  def handle_controller(exception_name, controller_class, network_exceptions)
    network_controllers = [
      RemoteFollowController
    ].freeze

    ignore_controller_errors = {
      'MediaProxyController' => ['ActiveRecord::RecordInvalid'],
    }.freeze

    return true if ignore_controller_errors[controller_class.name]&.include?(exception_name)

    # SignatureVerificationがincludeされているコントローラ or 通信が頻繁に発生するコントローラではネットワーク系のエラーを無視
    if controller_class.ancestors.include?(SignatureVerification) || network_controllers.include?(controller_class)
      return true if network_exceptions.include?(exception_name)
    end

    false
  end

  config.ignore_if do |exception, options|
    exception_name = exception.class.name

    # includes invalid characters
    ignore_exception = exception_name == 'ActiveRecord::RecordInvalid' && exception.message.end_with?('includes invalid characters')

    unless ignore_exception
      sidekiq = (options || {})&.dig(:data, :sidekiq)
      ignore_exception = handle_sidekiq(exception_name, sidekiq, network_exceptions) if sidekiq
    end

    unless ignore_exception
      controller_class = (options || {})&.dig(:env, 'action_controller.instance')&.class
      ignore_exception = handle_controller(exception_name, controller_class, network_exceptions) if controller_class
    end

    !Rails.env.production? || ignore_exception
  end

  config.error_grouping = true

  if ENV['EXCEPTION_NOTIFICATION_EMAIL'] && ENV['LOCAL_DOMAIN']
    # Email notifier sends notifications by email.
    config.add_notifier :email,
      email_prefix: '[pawoo-errors] ',
      sender_address: %{"pawoo Errors" <errors@#{ENV['LOCAL_DOMAIN']}>},
      exception_recipients: ENV['EXCEPTION_NOTIFICATION_EMAIL'].split(',')
  end

  if Rails.application.secrets.slack[:error_webhook_url] && Rails.application.secrets.slack[:error_channel]
    config.add_notifier :slack,
      webhook_url: Rails.application.secrets.slack[:error_webhook_url],
      channel: Rails.application.secrets.slack[:error_channel]
  end
end
