require "rails_helper"

describe Statistic, type: :model do
  describe "validation" do
    subject { build(:statistic) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_uniqueness_of(:date) }
  end
end
