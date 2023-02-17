class AutopilotPusher
  include HTTParty
  base_uri "https://api2.autopilothq.com/v1"

  def initialize(*args, &block)
    super()
    @headers = {
      autopilotapikey: Rails.application.credentials[:autopilot_api_key] || "dummykey",
      "Content-Type": "application/json"
    }
  end

  def self.post(*args, &block)
    super(*args, &block) if Rails.env == "production" || Rails.env == "test"
  end

  def push_ambassador_info(user)
    options = {
      headers: @headers,
      body: {
        contact: {
          Email: user.individual.email,
          custom: {
            "integer--visites--generees": user.generated_visits,
            "string--Code--ambassadeur": user.individual.public_slug
          }
        }
      }.to_json
    }

    self.class.post("/contact", options)
  end
end
