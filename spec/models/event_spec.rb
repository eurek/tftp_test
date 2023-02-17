require "rails_helper"

RSpec.describe Event, type: :model do
  describe "validations" do
    subject { FactoryBot.build(:event) }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:locale) }
    it { is_expected.to validate_presence_of(:registration_link) }
    it { is_expected.to validate_presence_of(:external_uid) }
    it { is_expected.to validate_uniqueness_of(:external_uid) }
    it { is_expected.to have_many(:notifications) }
    it {
      is_expected.to define_enum_for(:category).with_values(
        conference: "conference",
        workshop: "workshop",
        videoconference: "videoconference",
        course: "course",
      ).backed_by_column_of_type(:string)
    }

    it "should allow nil category" do
      expect {
        FactoryBot.create(:event, category: nil)
      }.to change {
        Event.count
      }
    end
  end

  describe "incoming scope" do
    it "should include events happening in the next 3 weeks" do
      event_1 = FactoryBot.create(:event, date: Time.now + 1.day)
      event_2 = FactoryBot.create(:event, date: Time.now + 10.day)

      expect(Event.incoming.include?(event_1.reload)).to be true
      expect(Event.incoming.include?(event_2.reload)).to be true
    end

    it "should not include events happening in more than three weeks" do
      event = FactoryBot.create(:event, date: Time.now + 22.day)

      expect(Event.incoming.include?(event.reload)).to be false
    end

    it "should include events happening the same day even if the time is passed" do
      stubbed_time = Time.new(2021, 5, 13, 10, 0)
      allow(Time).to receive(:now).and_return(stubbed_time)
      allow(Date).to receive(:today).and_return(stubbed_time.to_date)
      event = FactoryBot.create(:event, date: stubbed_time - 2.hours)

      expect(Event.incoming.include?(event.reload)).to be true
    end
  end

  describe "passed scope" do
    it "should include passed event" do
      event_1 = FactoryBot.create(:event, date: Time.now - 2.day)
      event_2 = FactoryBot.create(:event, date: Time.now - 10.day)

      expect(Event.passed.include?(event_1.reload)).to be true
      expect(Event.passed.include?(event_2.reload)).to be true
    end

    it "should not include events older than three weeks" do
      event = FactoryBot.create(:event, date: Time.now - 22.day)

      expect(Event.passed.include?(event.reload)).to be false
    end

    it "should not include events happening the same day even if the time is passed" do
      stubbed_time = Time.new(2021, 5, 13, 10, 0)
      allow(Time).to receive(:now).and_return(stubbed_time)
      allow(Date).to receive(:today).and_return(stubbed_time.to_date)
      event = FactoryBot.create(:event, date: stubbed_time - 2.hours)

      expect(Event.passed.include?(event.reload)).to be false
    end
  end

  describe "callback" do
    it "should downcase locale before saving it" do
      event = FactoryBot.create(:event, locale: "It")

      expect(event.reload.locale).to eq("it")
    end
  end
end
