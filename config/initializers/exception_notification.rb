require 'exception_notification/rails'
require 'exception_notification/sidekiq'

ExceptionNotification.configure do |config|
  config.ignored_exceptions += %w(
    ActionController::InvalidAuthenticityToken
    ActionController::BadRequest
    ActionController::UnknownFormat
    ActionController::ParameterMissing
    ActiveRecord::RecordNotUnique
    HTTP::TimeoutError
    HTTP::ConnectionError
    HTTP::Redirector::TooManyRedirectsError
    HTTP::Redirector::EndlessRedirectError
    OpenSSL::SSL::SSLError
    Mastodon::UnexpectedResponseError
  )

  ignore_workers = %w[
  ].freeze

  ignore_worker_errors = {
    'ActiveRecord::RecordInvalid' => ['ActivityPub::ProcessingWorker', 'LinkCrawlWorker'],
  }.freeze

  ignore_job_errors = {
    'ActiveJob::DeserializationError' => ['ActionMailer::DeliveryJob']
  }.freeze

  config.ignore_if do |exception, options|
    sidekiq = (options || {})&.dig(:data, :sidekiq)
    if sidekiq
      worker_class = sidekiq.dig(:job, 'class')
      ignore_worker = ignore_workers.include?(worker_class)
      ignore_worker ||= ignore_worker_errors[exception.class.name]&.include?(worker_class)

      if worker_class == 'ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper'
        ignore_worker ||= ignore_job_errors[exception.class.name]&.include?(sidekiq.dig(:job, 'wrapped'))
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
