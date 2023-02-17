require "rails_helper"

RSpec.describe Notification, type: :model do
  it { is_expected.to belong_to(:subject) }
end
