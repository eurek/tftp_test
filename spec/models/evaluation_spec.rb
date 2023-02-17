require "rails_helper"

RSpec.describe Evaluation, type: :model do
  it { is_expected.to belong_to(:individual) }
  it { is_expected.to belong_to(:innovation) }
end
