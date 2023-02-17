Sentry.init do |config|
  config.dsn = Rails.application.credentials[:sentry_dsn]
  config.breadcrumbs_logger = [:active_support_logger]

  # We didn't activate performance monitoring because new-relic heroku addon is already doing it
  # To activate performance monitoring, set one of these options.
  # We recommend adjusting the value in production:
  # config.traces_sample_rate = 0.5
  # or
  # config.traces_sampler = lambda do |context|
  #   true
  # end

  # Send notifications in background job
  config.async = lambda { |event|
    SentryJob.perform_later(event)
  }
end
