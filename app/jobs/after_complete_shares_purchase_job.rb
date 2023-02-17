class AfterCompleteSharesPurchaseJob < ActiveJob::Base
  queue_as :default

  def perform(shares_purchase_id)
    shares_purchase = SharesPurchase.find(shares_purchase_id)
    if shares_purchase.completed_status? &&
        shares_purchase.paid_payment? &&
        shares_purchase.subscription_bulletin.attached?

      unless shares_purchase.debit_gocardless_payment_method?
        ZapierNotifier.new.send_confirmation_email(shares_purchase)
      end

      # TODO: Gérer le cas des achats par des entreprises
      shares_purchase.individual.notify_new_shareholder

      CommunicationLocaleSetter.new(shares_purchase.individual).set
      if new_shareholder?(shares_purchase.individual)
        user = User.create(individual: shares_purchase.individual)
        set_company_admin(shares_purchase.company, user)
      elsif shares_purchase.individual.user.present? && shares_purchase.individual.user.pending
        shares_purchase.individual.user.resend_confirmation_instructions
      end
    else
      AfterCompleteSharesPurchaseJob.set(wait: 5.minutes).perform_later(shares_purchase_id)
      Sentry.capture_message(
        "Shares Purchase completed status but not paid or no documents attached",
        extra: {
          shares_purchase_id: shares_purchase.id,
          completed_status: shares_purchase.completed_status?,
          paid_payment: shares_purchase.paid_payment?,
          subscription_bulletin_attached?: shares_purchase.subscription_bulletin.attached?,
          subscription_bulletin_certificate_attached?: shares_purchase.subscription_bulletin_certificate.attached?
        }
      )
    end
  end

  private

  def set_company_admin(company, user)
    company.update(admin: user) if company.present? && company.admin.blank?
  end

  def new_shareholder?(individual)
    individual.shares_purchases.where(status: "completed").count == 1 && individual.user.nil?
  end
end
