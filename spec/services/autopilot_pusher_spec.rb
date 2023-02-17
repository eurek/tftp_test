require "rails_helper"

describe AutopilotPusher do
  let(:api_url) { AutopilotPusher.base_uri }

  describe "#push_ambassador_info" do
    let(:push_ambassador_info_url) { api_url + "/contact" }

    it "pushes public_slug and generated visits to autopilot" do
      user = FactoryBot.create(:user, generated_visits: 2)
      stub = stub_request(:post, /#{Regexp.quote(push_ambassador_info_url)}/)
        .with(
          headers: {
            autopilotapikey: Rails.application.credentials[:autopilot_api_key] || "dummykey"
          },
          body: {
            contact: {
              Email: user.individual.email,
              custom: {
                "integer--visites--generees": user.generated_visits,
                "string--Code--ambassadeur": user.individual.public_slug
              }
            }
          }
        ).to_return({status: 200, body: {contact_id: "person_6157E0A3-ACAB-42AC-A094-F63C1CFD4DE5"}.to_json})

      AutopilotPusher.new.push_ambassador_info(user)

      expect(stub).to have_been_requested
    end
  end
end
