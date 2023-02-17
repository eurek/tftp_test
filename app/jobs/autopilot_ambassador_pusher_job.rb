class AutopilotAmbassadorPusherJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
    user = User.find(user_id)
    AutopilotPusher.new.push_ambassador_info(user)
  end
end
