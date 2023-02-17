require "rails_helper"

RSpec.describe User, type: :model do
  describe "validations" do
    subject { FactoryBot.build(:user) }
    it { is_expected.to have_many(:companies).with_foreign_key(:admin_id) }
    it { is_expected.to have_many(:created_companies).class_name("Company").with_foreign_key("creator_id") }
    it { is_expected.to belong_to(:individual) }
  end

  describe "#is_admin?" do
    it "returns true is the user is admin of one company" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:company, admin: user)

      expect(user.is_admin?).to be true
    end

    it "returns true is the user is admin of several companies" do
      user = FactoryBot.create(:user)
      2.times do
        FactoryBot.create(:company, admin: user)
      end

      expect(user.is_admin?).to be true
    end

    it "returns false is the user is not a company admin" do
      user = FactoryBot.create(:user)

      expect(user.is_admin?).to be false
    end
  end
end
