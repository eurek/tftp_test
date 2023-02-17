class DetectSharesPurchaseDuplicatesJob < ActiveJob::Base
  queue_as :default

  def perform(shares_purchase_id)
    shares_purchase = SharesPurchase.find(shares_purchase_id)
    individual = shares_purchase.individual
    possible_duplicates = SharesPurchase
      .where(individual: individual)
      .where.not(status: :canceled)
      .where("form_completed_at > ?", shares_purchase.form_completed_at - 24.hours)
      .where("form_completed_at <= ?", shares_purchase.form_completed_at)

    if possible_duplicates.count > 1
      possible_duplicates.update_all(is_a_duplicate: true)
    end
  end
end
