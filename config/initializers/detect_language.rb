DetectLanguage.configure do |config|
  config.api_key = Rails.application.credentials.dig(:detect_language_api_key)

  # enable secure mode (SSL) if you are passing sensitive data
  config.secure = true
  config.http_open_timeout = 10
  config.http_read_timeout = 10
end
