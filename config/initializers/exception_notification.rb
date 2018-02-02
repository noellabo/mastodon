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
  )

  network_exceptions = %w[
    HTTP::StateError
    HTTP::TimeoutError
    HTTP::ConnectionError
    HTTP::Redirector::TooManyRedirectsError
    HTTP::Redirector::EndlessRedirectError
    OpenSSL::SSL::SSLError
  ].freeze

  ignore_workers = %w[
  ].freeze

  ignore_worker_errors = {
    'ActivityPub::ProcessingWorker' => ['ActiveRecord::RecordInvalid'],
    'LinkCrawlWorker' => ['ActiveRecord::RecordInvalid'].concat(network_exceptions),
  }.freeze

  ignore_job_errors = {
    'ActionMailer::DeliveryJob' => ['ActiveJob::DeserializationError']
  }.freeze

  config.ignore_if do |exception, options|
    sidekiq = (options || {})&.dig(:data, :sidekiq)
    if sidekiq
      exception_name = exception.class.name
      worker_class = sidekiq.dig(:job, 'class')

      ignore_worker = ignore_workers.include?(worker_class)
      ignore_worker ||= ignore_worker_errors[worker_class]&.include?(exception_name)

      # ActivityPub or Pubsubhubbub
      if worker_class.start_with?('ActivityPub::') || worker_class.start_with?('Pubsubhubbub::')
        ignore_worker ||= network_exceptions.include?(exception_name)
      end

      # ActiveJob
      if worker_class == 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper'
        ignore_worker ||= ignore_job_errors[sidekiq.dig(:job, 'wrapped')]&.include?(exception_name)
      end
    end

    !Rails.env.production? || ignore_worker
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
