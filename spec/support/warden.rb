# rubocop:disable Style/MixinUsage

include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do |config|
  config.after(:each) { Warden.test_reset! }
end
# rubocop:enable Style/MixinUsage
