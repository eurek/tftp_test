require "rails_helper"

describe Page, type: :model do
  it { is_expected.to validate_presence_of(:slug) }

  describe "uniqueness validation" do
    subject { FactoryBot.build(:page) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end
end
