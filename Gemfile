source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.3"

gem "rails", "~> 6.1.4"

gem "activeadmin"
gem "activeadmin_addons", github: "platanus/activeadmin_addons"
gem "activerecord-cte"
gem "active_storage_validations", "~> 1.0"
gem "autoprefixer-rails"
gem "aws-sdk-s3"
gem "blind_index"
# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", ">= 1.1.0", require: false
gem "browser"
gem "country_select"
gem "detect_language"
gem "devise"
gem "dotiw"
gem "draper", github: "drapergem/draper"
gem "factory_bot_rails"
gem "flutie"
gem "geocoder"
gem "groupdate"
gem "httparty"
gem "hiredis", "~> 0.6"
# force version  àf i18n to prevent conflict
gem "i18n", "~> 1.12"
gem "image_processing", "~> 1.2"
gem "jbuilder", "~> 2.5"
gem "kaminari"
gem "lockbox", "~> 1.1"
gem "mobility", "~> 1.1"
gem "nokogiri"
gem "pg", ">= 1.4", "< 2.0"
gem "pghero"
gem "pg_query", ">= 0.9.0"
gem "pg_search"
gem "phonelib", "~> 0.7.4"
gem "puma", "< 6"
gem "rack-cors"
gem "rack-timeout"
gem "rails-i18n", "~> 7.0"
gem "redis", "~> 5.0"
gem "sass-rails", "~> 6.0"
gem "scout_apm", "~> 5.3"
gem "sendgrid-actionmailer"
gem "sentry-ruby"
gem "sentry-rails"
gem "sentry-sidekiq"
gem "sidekiq"
gem "sidekiq-failures", "~> 1.0"
gem "simple_form"
gem "turbolinks", "~> 5"
gem "uglifier", ">= 1.3.0"
gem "webpacker"
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'mini_racer', platforms: :ruby

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  gem "awesome_print"
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem "byebug", platforms: [:mri, :mingw, :x64_mingw]
  gem "capybara-email"
  gem "dotenv-rails"
  gem "faker", "~> 3.1"
  gem "rspec-rails", "~> 6.0"
  gem "rubocop", "~> 1.34", require: false
  gem "rubocop-performance", require: false
  gem "shoulda-matchers"
end

group :development do
  gem "letter_opener", "~> 1.8"
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem "web-console", ">= 3.3.0"
end

group :test do
  gem "capybara", ">= 3.38"
  gem "database_cleaner"
  gem "orderly"
  gem "pry"
  gem "rspec_junit_formatter"
  gem "selenium-webdriver"
  gem "simplecov", require: false
  gem "stackprof", "~> 0.2.22"
  gem "timecop"
  gem "webdrivers"
  gem "webmock"
end

group :rake do
  gem "highline", "~> 2.0"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

gem "forest_liana", "~> 7.6"
