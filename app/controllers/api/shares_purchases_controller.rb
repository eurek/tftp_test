class Api::SharesPurchasesController < Api::ApiController
  skip_before_action :authenticate_api!, only: :zoho_sign

  def create
    purchase = ActiveRecord::Base.transaction do
      individual = create_or_update_individual
      company = Company.match_or_create(company_params, individual.user) if params.dig(:company, :name).present?
      SharesPurchase.create!(shares_purchases_params.merge({
        individual: individual,
        company: company,
        company_info: params.dig(:company, :name).present? ? company_params : nil
      }))
    end

    json = purchase.attributes.as_json
    render json: json, status: :ok
  end

  def show
    fields = params[:fields] || []
    shares_purchase = SharesPurchase.find_by(typeform_answer_uid: params[:typeform_answer_uid])
    return head :not_found if shares_purchase.nil?
    render json: shares_purchase.slice(:typeform_answer_uid, *fields), status: :ok
  end

  def zoho_sign
    return render json: {}, status: :unauthorized if request.user_agent != "ZohoSign"

    message = ZohoSign.new.handle_sign_webhook(params)
    if ["no_individual", "no_shares"].include?(message)
      Sentry.capture_message "Subscription Bulletin signed but no corresponding purchase", extra: {
        reason: message,
        params: params
      }
    end
    render json: {}, status: :ok
  end

  def attach_subscription_bulletin
    shares_purchase = SharesPurchase.find(params.dig(:shares_purchase, :id))
    shares_purchase.subscription_bulletin.attach_from_url(params.dig(:shares_purchase, :url))
    shares_purchase.save!

    render json: {}, status: :ok
  end

  private

  def shares_purchases_params
    params.require(:shares_purchase).permit(:external_uid, :amount, :completed_at, :typeform_answer_uid,
      :form_completed_at, :payment_method, :payment_status, :status, :paid_at, :origin, :shares_classes,
      :typeform_language, :utm_source, :utm_medium, :utm_campaign, :typeform_id, :gift_coupon_buyer_typeform_answer_uid,
      :gift_coupon_amount, :is_a_duplicate)
  end
end
