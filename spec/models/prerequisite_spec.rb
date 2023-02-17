require "rails_helper"

RSpec.describe Prerequisite, type: :model do
  it { is_expected.to belong_to(:necessary) }
  it { is_expected.to belong_to(:dependent) }
end
