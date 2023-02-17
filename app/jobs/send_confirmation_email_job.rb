class SendConfirmationEmailJob < ActiveJob::Base
  queue_as :default

  def perform(shares_purchase_id)
    shares_purchase = SharesPurchase.find(shares_purchase_id)
    return unless shares_purchase.completed_status!

    ZapierNotifier.new.send_confirmation_email(shares_purchase)
  end
end
