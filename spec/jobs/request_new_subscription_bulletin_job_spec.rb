require "rails_helper"

RSpec.describe RequestNewSubscriptionBulletinJob, type: :job do
  describe "#perform" do
    before(:each) do
      @stub = stub_request(:post, "https://hooks.zapier.com/hooks/catch/5761965/bn5qlb7/")
        .to_return({status: 200, body: "{}"})
    end

    it "requests generation of new subscription bulletin" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      RequestNewSubscriptionBulletinJob.perform_now(shares_purchase.id)

      expect(@stub).to have_been_requested.once
    end
  end
end
