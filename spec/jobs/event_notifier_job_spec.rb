require "rails_helper"

RSpec.describe EventNotifierJob, type: :job do
  describe "#perform" do
    it "creates notification for event that has started within last 15 minutes by default" do
      event = FactoryBot.create(:event, date: Time.now.round - 5.minutes)

      expect { EventNotifierJob.perform_now }.to change { Notification.count }.by 1
      expect(Notification.last.subject).to eq(event)
      expect(Notification.last.created_at).to eq(event.date)
    end

    it "does not create a notification if notification for this event already exists" do
      event = FactoryBot.create(:event, date: Time.now - 5.minutes)
      Notification.create(subject: event)

      expect { EventNotifierJob.perform_now }.not_to change { Notification.count }
    end

    it "does not create a notification for future events" do
      FactoryBot.create(:event, date: Time.now + 1.minute)

      expect { EventNotifierJob.perform_now }.not_to change { Notification.count }
    end
  end
end
