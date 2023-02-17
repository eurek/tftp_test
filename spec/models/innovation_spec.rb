require "rails_helper"

RSpec.describe Innovation, type: :model do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to validate_presence_of(:external_uid) }
  it { is_expected.to validate_uniqueness_of(:external_uid) }
  it { is_expected.to belong_to(:action_domain).optional }
  it { is_expected.to belong_to(:action_lever).optional }
  it {
    is_expected.to belong_to(:submission_episode).optional.class_name("Episode")
      .with_foreign_key("submission_episode_id")
  }
  it { is_expected.to have_many(:notifications) }
  it { is_expected.to have_one(:funded_innovation).optional.dependent(:destroy) }
  it { is_expected.to validate_numericality_of(:rating).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:rating).is_less_than_or_equal_to(5) }
  it {
    is_expected.to define_enum_for(:status).with_values(
      received: "received",
      submitted_to_evaluations: "submitted_to_evaluations",
      submitted_to_scientific_comity: "submitted_to_scientific_comity",
      submitted_to_economical_tests: "submitted_to_economical_tests",
      submitted_to_general_assembly: "submitted_to_general_assembly",
      star: "star"
    ).with_suffix(:status).backed_by_column_of_type(:string)
  }
  it { is_expected.to have_many(:evaluations).dependent(:destroy) }
  it { is_expected.to have_many(:evaluators).through(:evaluations).source(:individual) }

  describe "#is_being_evaluated?" do
    it "should return true when innovation's selection period equals current episode period" do
      current_episode = FactoryBot.create(
        :episode, number: 2, season_number: 1, started_at: Date.today - 1.months, finished_at: Date.today + 1.month
      )
      innovation = FactoryBot.build(:innovation, selection_period: current_episode.decorate.display_code)

      expect(innovation.is_being_evaluated?).to be true
    end

    it "should return false when innovation's selection period is nil" do
      innovation = FactoryBot.build(:innovation, selection_period: nil)

      expect(innovation.is_being_evaluated?).to be false
    end

    it "should return false when innovation's selection period does not equal current one" do
      FactoryBot.create(
        :episode, number: 2, season_number: 1, started_at: Date.today - 1.months, finished_at: Date.today + 1.month
      )
      innovation = FactoryBot.build(:innovation, selection_period: "S01E03")

      expect(innovation.is_being_evaluated?).to be false
    end
  end

  describe "notify_new_evaluation callback" do
    it "should not create notification on innovation creation if evaluations_amount is 0 " do
      expect { FactoryBot.create(:innovation, evaluations_amount: 0) }.not_to change {
        Notification.count
      }
    end

    it "should not create notification if evaluations_amount is decremented " do
      innovation = FactoryBot.create(:innovation, evaluations_amount: 2)

      expect { innovation.update(evaluations_amount: 1) }.not_to change {
        Notification.count
      }
    end

    it "should not create notification if evaluations_amount is nullified " do
      innovation = FactoryBot.create(:innovation, evaluations_amount: 1)

      expect { innovation.update(evaluations_amount: nil) }.not_to change {
        Notification.count
      }
    end

    it "should create notification when evaluations_amount is incremented" do
      innovation = FactoryBot.create(:innovation)

      expect { innovation.update(evaluations_amount: 1) }.to change {
        Notification.count
      }.by 1
    end

    it "should create only one notification when evaluations_amount is incremented by more than one" do
      innovation = FactoryBot.create(:innovation)

      expect { innovation.update(evaluations_amount: 5) }.to change {
        Notification.count
      }.by 1
    end
  end
end
