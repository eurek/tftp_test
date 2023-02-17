require "rails_helper"

RSpec.describe AutopilotAmbassadorPusherJob, type: :job do
  describe "#perform" do
    before(:each) do
      @autopilot_pusher = double
      allow(@autopilot_pusher).to receive(:push_ambassador_info).and_return(
        {contact_id: "person_6157E0A3-ACAB-42AC-A094-F63C1CFD4DE5"}.to_json
      )
      allow(AutopilotPusher).to receive(:new).and_return(@autopilot_pusher)
    end

    it "calls autopilot pusher with user" do
      user = FactoryBot.create(:user)

      AutopilotAmbassadorPusherJob.perform_now(user.id)

      expect(@autopilot_pusher).to have_received(:push_ambassador_info).with(user)
    end
  end
end
