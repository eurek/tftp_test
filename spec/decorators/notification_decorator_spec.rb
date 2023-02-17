require "rails_helper"

RSpec.describe NotificationDecorator do
  include Rails.application.routes.url_helpers

  describe "#icon" do
    it "renders event icon for event notification" do
      event = FactoryBot.create(:event)
      notification = Notification.create(subject: event)

      expect(notification.decorate.icon).to eq("icones/events.svg")
    end

    it "renders innovation icon for innovation notification" do
      innovation = FactoryBot.create(:innovation)
      notification = Notification.create(subject: innovation)

      expect(notification.decorate.icon).to eq("icones/received_innovations.svg")
    end

    it "renders shareholder icon for individual notification or any other subject class" do
      individual = FactoryBot.create(:individual)
      notification = Notification.create(subject: individual)

      expect(notification.decorate.icon).to eq("icones/shareholders.svg")
    end
  end

  describe "#name" do
    it "renders event's title for event notification" do
      event = FactoryBot.create(:event)
      notification = Notification.create(subject: event)

      expect(notification.decorate.name).to eq(event.title)
    end

    it "renders innovation's name for innovation notification" do
      innovation = FactoryBot.create(:innovation)
      notification = Notification.create(subject: innovation)

      expect(notification.decorate.name).to eq(innovation.name)
    end

    it "renders shareholder's name for individual notification" do
      individual = FactoryBot.create(:individual)
      notification = Notification.create(subject: individual)

      expect(notification.decorate.name).to eq(individual.full_name)
    end

    it "raises an error if notification's subject class is neither of the accepted ones" do
      user = FactoryBot.create(:user)
      notification = Notification.create(subject: user)

      expect { notification.decorate.name }.to raise_error("Unknown class")
    end
  end

  describe "#link" do
    it "renders events index path for event notification" do
      event = FactoryBot.create(:event)
      notification = Notification.create(subject: event)

      expect(notification.decorate.link).to eq(events_path)
    end

    it "renders innovations index path for innovation notification" do
      innovation = FactoryBot.create(:innovation)
      notification = Notification.create(subject: innovation)

      expect(notification.decorate.link).to eq(innovations_path)
    end

    it "renders shareholders index path for individual notification" do
      individual = FactoryBot.create(:individual)
      notification = Notification.create(subject: individual)

      expect(notification.decorate.link).to eq(shareholders_path)
    end

    it "raises an error if notification's subject class is neither of the accepted ones" do
      user = FactoryBot.create(:user)
      notification = Notification.create(subject: user)

      expect { notification.decorate.name }.to raise_error("Unknown class")
    end
  end
end
