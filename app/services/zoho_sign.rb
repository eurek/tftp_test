class ZohoSign
  include HTTParty
  base_uri "https://sign.zoho.eu/api/v1"

  AUTH_URL = "https://accounts.zoho.eu/oauth/v2/token".freeze
  PAYMENT_METHOD_MAPPER = {
    "CB" => ["gift_coupon", "card_stripe"],
    "VIR" => "transfer_ce"
  }.freeze

  def handle_sign_webhook(params, shares_purchase = nil)
    zoho_request = params[:requests] || {}
    zoho_request_id = zoho_request[:request_id]

    action = zoho_request.dig(:actions, 0, :action_type)
    status = zoho_request.dig(:actions, 0, :action_status)
    return "unknown_type" unless action == "SIGN"

    request_name = zoho_request.dig(:request_name) || ""
    return "not_a_bulletin" unless request_name.start_with?("BS_")

    individual_email = zoho_request.dig(:actions, 0, :recipient_email)
    individual = Individual.find_by_email(individual_email)
    return "no_individual" if !individual && status == "SIGNED"

    payment_method = PAYMENT_METHOD_MAPPER[request_name.split("_")[1]]

    shares_purchase ||= individual
      .shares_purchases
      .without_subscription_bulletin
      .where(payment_method: payment_method)
      .order(created_at: :desc)
      .first
    return "no_shares" if !shares_purchase && status == "SIGNED"

    if shares_purchase.present?
      shares_purchase.update(zoho_sign_request_id: zoho_request_id)

      download_documents(shares_purchase, zoho_request_id) if status == "SIGNED"
    end
  end

  def unique_signed_bulletin(recipient_email)
    documents = documents_list_for(recipient_email)

    zoho_requests = documents[:requests] || []
    filtered_requests = zoho_requests.filter do |request|
      action = request.dig(:actions, 0, :action_type)
      status = request.dig(:actions, 0, :action_status)
      request_name = request.dig(:request_name) || ""
      request_name.start_with?("BS_") && action == "SIGN" && status == "SIGNED"
    end

    return "no signed bulletin" if filtered_requests.blank?
    return "more than one signed bulletin" if filtered_requests.size > 1

    filtered_requests.first
  end

  def unique_signed_bulletin_around(recipient_email, lower_signed_at, higher_signed_at, payment_method)
    documents = documents_list_for(recipient_email)

    zoho_requests = documents[:requests] || []
    filtered_requests = zoho_requests.filter do |request|
      action = request.dig(:actions, 0, :action_type)
      status = request.dig(:actions, 0, :action_status)
      request_name = request.dig(:request_name) || ""
      signed_at_timestamp = request.dig(:action_time) || 1000
      signed_at = DateTime.strptime((signed_at_timestamp / 1000).to_s, "%s")
      payment_method_prefix = payment_prefix(payment_method)

      request_name.start_with?("BS_#{payment_method_prefix}") &&
        action == "SIGN" &&
        status == "SIGNED" &&
        signed_at >= lower_signed_at &&
        signed_at <= higher_signed_at
    end

    return "no signed bulletin" if filtered_requests.blank?
    return "more than one signed bulletin" if filtered_requests.size > 1

    filtered_requests.first
  end

  def signed_bulletin_around(recipient_email, lower_signed_at, higher_signed_at, payment_method)
    documents = documents_list_for(recipient_email, "ASC")

    zoho_requests = documents[:requests] || []
    filtered_requests = zoho_requests.filter do |request|
      action = request.dig(:actions, 0, :action_type)
      status = request.dig(:actions, 0, :action_status)
      request_name = request.dig(:request_name) || ""
      signed_at_timestamp = request.dig(:action_time) || 1000
      signed_at = DateTime.strptime((signed_at_timestamp / 1000).to_s, "%s")
      payment_method_prefix = payment_prefix(payment_method)

      request_name.start_with?("BS_#{payment_method_prefix}") &&
        action == "SIGN" &&
        status == "SIGNED" &&
        signed_at >= lower_signed_at &&
        signed_at <= higher_signed_at
    end

    filtered_requests
  end

  private

  def payment_prefix(payment_method)
    if payment_method == "card_stripe" || payment_method == "gift_coupon"
      "CB"
    elsif payment_method == "transfer_ce"
      "VIR"
    else
      ""
    end
  end

  def documents_list_for(recipient_email, sort_order = "DESC")
    token = generate_token
    options = {
      headers: {
        "Authorization" => "Zoho-oauthtoken #{token}"
      },
      query: {
        data: {
          page_context:
            {
              row_count: 20,
              start_index: 1,
              search_columns: {recipient_email: recipient_email},
              sort_column: "created_time",
              sort_order: sort_order
            }
        }.to_json
      }
    }

    self.class.get("/requests", options).parsed_response.deep_symbolize_keys
  end

  def download_documents(shares_purchase, request_id)
    @unauthorized_counter ||= 0
    token = generate_token
    headers = {
      "Authorization" => "Zoho-oauthtoken #{token}"
    }
    shares_purchase.subscription_bulletin.attach_from_url(
      "#{self.class.base_uri}/requests/#{request_id}/pdf",
      headers
    )
    shares_purchase.subscription_bulletin_certificate.attach_from_url(
      "#{self.class.base_uri}/requests/#{request_id}/completioncertificate",
      headers
    )
    shares_purchase.save!
  rescue OpenURI::HTTPError => e
    if /401/.match?(e.message) && @unauthorized_counter < 1
      @unauthorized_counter += 1
      Rails.cache.delete("zohosign-token")
      download_documents(shares_purchase, request_id)
    else
      Sentry.capture_message(
        "Couldn't download subscription bulletin",
        extra: {error: e, individual: shares_purchase.individual_id}
      )
    end
  end

  def generate_token
    Rails.cache.fetch("zohosign-token", expires_in: 50.minutes) do
      params = {
        client_id: Rails.application.credentials.dig(:zohosign, :client_id),
        client_secret: Rails.application.credentials.dig(:zohosign, :client_secret),
        refresh_token: Rails.application.credentials.dig(:zohosign, :refresh_token),
        grant_type: "refresh_token"
      }

      json = HTTParty.post(AUTH_URL, {
        body: params,
        headers: {
          "Content-Type" => "application/x-www-form-urlencoded",
          "charset" => "utf-8"
        }
      })
      json["access_token"]
    end
  end
end
