require "rails_helper"

describe ZapierNotifier do
  before(:all) do
    @api_url = ZapierNotifier.base_uri
  end

  describe "#notify_individual_email_changed" do
    let(:api_email_changed_url) { @api_url + "/bi3sbfg/" }

    it "sends new email and old one if user has changed email" do
      individual = FactoryBot.create(:individual, email: "old@email.com")
      stub = stub_request(:post, /#{Regexp.quote(api_email_changed_url)}/)
        .with(body: {
          user_airtable_id: individual.external_uid,
          old_email: "old@email.com",
          new_email: "new@email.com"
        })
        .to_return({status: 200, body: "{}"})

      individual.update(email: "new@email.com")

      expect(stub).to have_been_requested
    end
  end

  describe "#request_new_subscription_bulletin" do
    let(:api_request_new_subscription_bulletin_url) { @api_url + "/bn5qlb7/" }

    it "sends all necessary infos to zapier when company_purchase purchase" do
      shares_purchase = FactoryBot.create(:shares_purchase, :from_company,
        company_info: {registration_number: "7387483649", name: "Nada"})

      stub = stub_request(:post, /#{Regexp.quote(api_request_new_subscription_bulletin_url)}/)
        .with(body: {
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
          utm_campaign: shares_purchase.utm_campaign,
          company_name: shares_purchase.company.name,
          company_full_address: shares_purchase.company.address,
          company_street_address: shares_purchase.company.street_address,
          company_zip_code: shares_purchase.company.zip_code,
          company_city: shares_purchase.company.city,
          company_country: shares_purchase.company.country,
          company_registration_number: shares_purchase.company_info.fetch("registration_number")
        })
        .to_return({status: 200, body: "{}"})

      ZapierNotifier.new.request_new_subscription_bulletin(shares_purchase)

      expect(stub).to have_been_requested
    end

    it "sends all necessary infos to zapier when individual purchase" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      stub = stub_request(:post, /#{Regexp.quote(api_request_new_subscription_bulletin_url)}/)
        .with(body: {
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
          utm_campaign: shares_purchase.utm_campaign,
          date_of_birth: shares_purchase.individual.date_of_birth,
          individual_street_address: shares_purchase.individual.address,
          individual_zip_code: shares_purchase.individual.zip_code,
          individual_city: shares_purchase.individual.city,
          individual_country: shares_purchase.individual.country
        })
        .to_return({status: 200, body: "{}"})

      ZapierNotifier.new.request_new_subscription_bulletin(shares_purchase)

      expect(stub).to have_been_requested
    end
  end

  describe "#request_new_subscription_bulletin_recurring" do
    let(:api_request_new_subscription_bulletin_url) { @api_url + "/bntgg05/" }

    it "sends all necessary infos to zapier when individual purchase" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      stub = stub_request(:post, /#{Regexp.quote(api_request_new_subscription_bulletin_url)}/)
        .with(body: {
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
          utm_campaign: shares_purchase.utm_campaign,
          date_of_birth: shares_purchase.individual.date_of_birth,
          individual_street_address: shares_purchase.individual.address,
          individual_zip_code: shares_purchase.individual.zip_code,
          individual_city: shares_purchase.individual.city,
          individual_country: shares_purchase.individual.country
        })
        .to_return({status: 200, body: "{}"})

      ZapierNotifier.new.request_new_subscription_bulletin_recurring(shares_purchase)

      expect(stub).to have_been_requested
    end
  end

  describe "#send_email_with_bank_details" do
    let(:send_email_with_bank_details_url) { @api_url + "/bn5ksml/" }

    it "sends all necessary infos to zapier when company_purchase purchase" do
      shares_purchase = FactoryBot.create(:shares_purchase, :from_company,
        company_info: {registration_number: "7387483649", name: "Nada"})

      stub = stub_request(:post, /#{Regexp.quote(send_email_with_bank_details_url)}/)
        .with(body: {
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
          utm_campaign: shares_purchase.utm_campaign,
          company_name: shares_purchase.company.name,
          company_full_address: shares_purchase.company.address,
          company_street_address: shares_purchase.company.street_address,
          company_zip_code: shares_purchase.company.zip_code,
          company_city: shares_purchase.company.city,
          company_country: shares_purchase.company.country,
          company_registration_number: shares_purchase.company_info.fetch("registration_number")
        })
        .to_return({status: 200, body: "{}"})

      ZapierNotifier.new.send_email_with_bank_details(shares_purchase)

      expect(stub).to have_been_requested
    end

    it "sends all necessary infos to zapier when individual purchase" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      stub = stub_request(:post, /#{Regexp.quote(send_email_with_bank_details_url)}/)
        .with(body: {
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
          utm_campaign: shares_purchase.utm_campaign,
          date_of_birth: shares_purchase.individual.date_of_birth,
          individual_street_address: shares_purchase.individual.address,
          individual_zip_code: shares_purchase.individual.zip_code,
          individual_city: shares_purchase.individual.city,
          individual_country: shares_purchase.individual.country
        })
        .to_return({status: 200, body: "{}"})

      ZapierNotifier.new.send_email_with_bank_details(shares_purchase)

      expect(stub).to have_been_requested
    end
  end

  describe "#send_confirmation_email" do
    let(:send_confirmation_email_url) { @api_url + "/bn5k7qt/" }

    it "sends all necessary infos to zapier when company_purchase purchase" do
      shares_purchase = FactoryBot.create(:shares_purchase, :from_company,
        company_info: {registration_number: "7387483649", name: "Nada"})

      stub = stub_request(:post, /#{Regexp.quote(send_confirmation_email_url)}/)
        .with(body: {
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
          utm_campaign: shares_purchase.utm_campaign,
          company_name: shares_purchase.company.name,
          company_full_address: shares_purchase.company.address,
          company_street_address: shares_purchase.company.street_address,
          company_zip_code: shares_purchase.company.zip_code,
          company_city: shares_purchase.company.city,
          company_country: shares_purchase.company.country,
          company_registration_number: shares_purchase.company_info.fetch("registration_number")
        })
        .to_return({status: 200, body: "{}"})

      ZapierNotifier.new.send_confirmation_email(shares_purchase)

      expect(stub).to have_been_requested
    end

    it "sends all necessary infos to zapier when individual purchase" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      stub = stub_request(:post, /#{Regexp.quote(send_confirmation_email_url)}/)
        .with(body: {
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
          utm_campaign: shares_purchase.utm_campaign,
          date_of_birth: shares_purchase.individual.date_of_birth,
          individual_street_address: shares_purchase.individual.address,
          individual_zip_code: shares_purchase.individual.zip_code,
          individual_city: shares_purchase.individual.city,
          individual_country: shares_purchase.individual.country
        })
        .to_return({status: 200, body: "{}"})

      ZapierNotifier.new.send_confirmation_email(shares_purchase)

      expect(stub).to have_been_requested
    end
  end
end
