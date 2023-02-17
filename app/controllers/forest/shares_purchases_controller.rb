class Forest::SharesPurchasesController < ForestLiana::SmartActionsController
  # TODO: Test this in request spec
  def mark_as_paid
    shares_purchase = set_shares_purchase

    if shares_purchase.paid_payment?
      render status: 400, json: {error: "The shares purchase is already paid!"}
    elsif shares_purchase.update(payment_status: "paid")
      render json: {success: "Shares purchase marked as paid!"}
    else
      render status: 400, json: {error: "There has been an error."}
    end
  end

  def request_subscription_bulletin
    shares_purchase_ids = ForestLiana::ResourcesGetter.get_ids_from_request(params, forest_user)

    shares_purchase_ids.each { |id| RequestNewSubscriptionBulletinJob.perform_later(id) }
    render json: {success: "Subscription bulletins has been sent!"}
  end

  def generate_subscription_bulletin_recurring
    shares_purchase_ids = ForestLiana::ResourcesGetter.get_ids_from_request(params, forest_user)

    shares_purchase_ids.each { |id| RequestNewSubscriptionBulletinRecurringJob.perform_later(id) }
    render json: {success: "Subscription bulletins for recurring shares purchases have been generated!"}
  end

  def send_confirmation_email
    shares_purchase_ids = ForestLiana::ResourcesGetter.get_ids_from_request(params, forest_user)

    shares_purchase_ids.each { |id| SendConfirmationEmailJob.perform_later(id) }
    render json: {success: "Confirmation emails have been sent!"}
  end

  def mark_as_not_duplicated
    shares_purchase_ids = ForestLiana::ResourcesGetter.get_ids_from_request(params, forest_user)

    if SharesPurchase.where(id: shares_purchase_ids).update_all(is_a_duplicate: false)
      render json: {success: "Shares Purchases marked as not duplicated"}
    else
      render status: 400, json: {error: "There has been an error."}
    end
  end

  def mark_as_duplicated
    shares_purchase_ids = ForestLiana::ResourcesGetter.get_ids_from_request(params, forest_user)

    if SharesPurchase.where(id: shares_purchase_ids).update_all(is_a_duplicate: true)
      render json: {success: "Shares Purchases marked as duplicated"}
    else
      render status: 400, json: {error: "There has been an error."}
    end
  end

  private

  def set_shares_purchase
    shares_purchase_id = ForestLiana::ResourcesGetter.get_ids_from_request(params, forest_user).first
    SharesPurchase.find(shares_purchase_id)
  end
end
