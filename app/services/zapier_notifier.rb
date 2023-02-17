class ZapierNotifier
  include HTTParty
  base_uri "https://hooks.zapier.com/hooks/catch/5761965"

  def self.post(*args, &block)
    super(*args, &block) if Rails.env == "production" || Rails.env == "test"
  end

  def notify_individual_email_changed(individual, old_email)
    options = {
      body: {
        user_airtable_id: individual.external_uid,
        old_email: old_email,
        new_email: individual.email
      }
    }

    self.class.post("/bi3sbfg/", options)
  end

  def notify_new_shares_purchase_by_company(shares_purchase)
    options = {
      body: {
        company_db_id: shares_purchase.company_id,
        shares_purchase_airtable_id: shares_purchase.external_uid,
        temporary_company_name: shares_purchase.company_info&.fetch("name", nil),
        company_name: shares_purchase.company&.name
      }
    }

    self.class.post("/bbgl7xq/", options)
  end

  def request_new_subscription_bulletin(shares_purchase)
    options = {body: shares_purchase_info(shares_purchase).to_json, headers: {"Content-Type" => "application/json"}}

    self.class.post("/bn5qlb7/", options)
  end

  def request_new_subscription_bulletin_recurring(shares_purchase)
    options = {body: shares_purchase_info(shares_purchase).to_json, headers: {"Content-Type" => "application/json"}}

    self.class.post("/bntgg05/", options)
  end

  def send_email_with_bank_details(shares_purchase)
    options = {body: shares_purchase_info(shares_purchase).to_json, headers: {"Content-Type" => "application/json"}}

    self.class.post("/bn5ksml/", options)
  end

  def send_confirmation_email(shares_purchase)
    options = {body: shares_purchase_info(shares_purchase).to_json, headers: {"Content-Type" => "application/json"}}

    self.class.post("/bn5k7qt/", options)
  end

  private

  def shares_purchase_info(shares_purchase)
    base_params = {
      record_id: shares_purchase.id,
      typeform_answer_id: shares_purchase.typeform_answer_uid,
      typeform_language: shares_purchase.typeform_language,
      amount: shares_purchase.amount,
      payment_method: shares_purchase.payment_method,
      payment_status: shares_purchase.payment_status,
      status: shares_purchase.status,
      transfer_reference: shares_purchase.transfer_reference,
      first_name: shares_purchase.individual.first_name,
      last_name: shares_purchase.individual.last_name,
      email: shares_purchase.individual.email,
      id_card_received: shares_purchase.individual.id_card_received,
      utm_source: shares_purchase.utm_source,
      utm_medium: shares_purchase.utm_medium,
      utm_campaign: shares_purchase.utm_campaign
    }
    if shares_purchase.company.present?
      base_params.merge(({
        company_name: shares_purchase.company.name,
        company_full_address: shares_purchase.company.address,
        company_street_address: shares_purchase.company.street_address,
        company_zip_code: shares_purchase.company.zip_code,
        company_city: shares_purchase.company.city,
        company_country: shares_purchase.company.country,
        company_registration_number: shares_purchase.company_info&.fetch("registration_number", nil)
      }))
    else
      base_params.merge(({
        date_of_birth: shares_purchase.individual.date_of_birth,
        individual_street_address: shares_purchase.individual.address,
        individual_zip_code: shares_purchase.individual.zip_code,
        individual_city: shares_purchase.individual.city,
        individual_country: shares_purchase.individual.country
      }))
    end
  end
end
