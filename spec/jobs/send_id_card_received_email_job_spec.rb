require "rails_helper"

RSpec.describe SendIdCardReceivedEmailJob, type: :job do
  include Capybara::Email::DSL

  describe "#perform" do
    it "sends id card received email if id_card_received is true" do
      individual = FactoryBot.create(:individual, id_card_received: true)

      SendIdCardReceivedEmailJob.perform_now(individual.id)

      expect(IndividualMailer.deliveries.count).to eq(1)
      open_email(individual.email)
      expect(current_email).to have_content(individual.first_name)
    end

    it "sets locale to individual communication language" do
      individual = FactoryBot.create(:individual, id_card_received: true, communication_language: :en)

      SendIdCardReceivedEmailJob.perform_now(individual.id)

      expect(I18n.locale).to eq(:en)
      expect(IndividualMailer.deliveries.count).to eq(1)
    end

    it "does nothing if id_card_received change is false" do
      individual = FactoryBot.create(:individual, id_card_received: false)

      expect {
        SendIdCardReceivedEmailJob.perform_now(individual.id)
      }.not_to change { IndividualMailer.deliveries.count }
    end
  end
end
