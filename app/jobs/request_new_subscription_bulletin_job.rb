class RequestNewSubscriptionBulletinJob < ActiveJob::Base
  queue_as :default

  def perform(shares_purchase_id)
    shares_purchase = SharesPurchase.find(shares_purchase_id)
    ZapierNotifier.new.request_new_subscription_bulletin(shares_purchase)
  end
end
