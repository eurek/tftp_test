require "rails_helper"

describe ContentTag, type: :model do
  it { is_expected.to belong_to(:content) }
  it { is_expected.to belong_to(:tag) }
end
