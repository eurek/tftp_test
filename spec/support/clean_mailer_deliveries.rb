RSpec.configure do |config|
  config.after(:each) { ActionMailer::Base.deliveries.clear }
end
