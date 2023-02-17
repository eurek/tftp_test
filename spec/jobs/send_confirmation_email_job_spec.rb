require "rails_helper"

RSpec.describe SendConfirmationEmailJob, type: :job do
  describe "#perform" do
    before(:each) do
      @stub = stub_request(:post, "https://hooks.zapier.com/hooks/catch/5761965/bn5k7qt/")
        .to_return({status: 200, body: "{}"})
    end

    it "requests sending of confirmation email" do
      shares_purchase = FactoryBot.create(:shares_purchase, status: :completed)

      SendConfirmationEmailJob.perform_now(shares_purchase.id)

      expect(@stub).to have_been_requested.once
    end

    it "does not requests sending of confirmation email if status is not completed" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      SendConfirmationEmailJob.perform_now(shares_purchase.id)

      expect(@stub).to have_been_requested.once
    end
  end
end
