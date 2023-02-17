require "rails_helper"

RSpec.describe Api::SharesPurchasesController, type: :request do
  let(:headers) do
    {
      "HTTP_AUTHORIZATION": Rails.application.credentials.dig(:external_api_secret)
    }
  end

  describe "create" do
    let(:json_keys) do
      %w[id amount completed_at company_id temporary_company_name created_at updated_at external_uid individual_id
         typeform_answer_uid admin_comments form_completed_at payment_method status paid_at origin shares_classes
         transfer_reference company_info official_date payment_status sponsor typeform_language utm_source utm_medium
         utm_campaign typeform_id gift_coupon_buyer_typeform_answer_uid gift_coupon_amount zoho_sign_request_id
         is_a_duplicate]
    end
    let(:params) do
      {
        individual: {
          email: "edith@piaf.fr",
          first_name: "Edith",
          last_name: "Piaf",
          date_of_birth: "27/11/1997",
          phone: "0033678543322",
          address: "1 rue du Chariot d'Or",
          zip_code: "69004",
          city: "Lyon",
          country: "FRA",
          communication_language: "fr",
          nationality: "Française",
          is_100_club: false,
          is_displayed: false,
          username: "edith_cuicui",
          stacker_role: "admin",
          origin: "linkedin",
          id_card_received: true
        },
        shares_purchase: {
          amount: 200,
          completed_at: "2021-02-08T11:09:00.000Z",
          external_uid: "some_shares_purchase_uid",
          typeform_answer_uid: "brlns56uj5ubzuuvbrlm5oewatplrsnj",
          typeform_language: "fr",
          form_completed_at: "2021-02-08T11:11:00.000Z",
          payment_method: "card_stripe",
          status: "pending",
          paid_at: "2021-02-08",
          origin: "event",
          shares_classes: "C",
          utm_source: "linkedin",
          utm_medium: "marcel",
          utm_campaign: "100k",
          typeform_id: "yenf6kb",
          gift_coupon_buyer_typeform_answer_uid: "achat_groupe_oreo_1",
          gift_coupon_amount: 130
        },
        # Badly implemented in zapier script so we check presence of params.dig(:company, :name)
        company: {
          is_displayed: false
        }
      }
    end

    it "returns 401 if secret is not as expected" do
      post api_shares_purchases_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    it "creates a new shares_purchase and a new individual if they don't exist" do
      post api_shares_purchases_path, params: params, headers: headers

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      expect(Individual.count).to eq(1)
      individual = Individual.last
      params[:individual].except(:date_of_birth, :origin).each do |key, value|
        expect(individual.send(key)).to eq(value)
      end
      expect(individual.date_of_birth).to eq Date.parse(params[:individual][:date_of_birth])
      expect(individual.origin).to eq([params[:individual][:origin]])

      expect(SharesPurchase.count).to eq(1)
      shares_purchase = SharesPurchase.last
      params[:shares_purchase].except(:completed_at, :paid_at, :form_completed_at).each do |key, value|
        expect(shares_purchase.send(key)).to eq(value)
      end
      params[:shares_purchase].slice(:completed_at, :form_completed_at).each do |key, value|
        expect(shares_purchase.send(key)).to eq(DateTime.parse(params[:shares_purchase][key]))
      end
      expect(shares_purchase.paid_at).to eq(Date.parse(params[:shares_purchase][:paid_at]))
      expect(shares_purchase.company_info).to eq(nil)
      expect(shares_purchase.individual).to eq(individual)
      expect(Company.count).to eq(0)
    end

    it "updates an existing individual if it already exists" do
      individual = FactoryBot.create(:individual, email: params[:individual][:email])

      post api_shares_purchases_path, params: params, headers: headers

      expect(response.status).to eq 200
      expect(response_json).to contain_keys json_keys

      expect(Individual.count).to eq(1)
      individual = Individual.last
      params[:individual].except(:date_of_birth, :origin).each do |key, value|
        expect(individual.send(key)).to eq(value)
      end
      expect(individual.date_of_birth).to eq Date.parse(params[:individual][:date_of_birth])
      expect(individual.origin).to eq([params[:individual][:origin]])

      expect(SharesPurchase.count).to eq(1)
    end

    describe "with company" do
      let(:company_params) {
        {
          name: "Edith Piaf",
          address: "18, Rue Des Lapins, 93017 Marcel, France",
          is_displayed: true,
          street_address: "18, Rue Des Lapins",
          zip_code: "93017",
          city: "Marcel",
          country: "France",
          registration_number: "Siret RCS de Chez Moi 891 274 294 00017",
          legal_form: "SARL",
          structure_size: "1 personne",
          website: "https://www.piaf-marcel.com"
        }
      }

      before(:each) do
        @open_corporates_url = "https://api.opencorporates.com/v0.4/companies/search"
        @open_corporates_none = {
          "api_version": "0.4",
          "results": {
            "companies": []
          }
        }.to_json
        stub_request(:get, /#{Regexp.quote(@open_corporates_url)}/).to_return(status: 200, body: @open_corporates_none)
      end

      it "creates a new company if company is present in params but does not match any in db" do
        post api_shares_purchases_path, params: params.merge({company: company_params}), headers: headers

        expect(response.status).to eq 200
        expect(response_json).to contain_keys json_keys

        expect(Individual.count).to eq(1)
        expect(SharesPurchase.count).to eq(1)
        expect(Company.count).to eq(1)
        company = Company.last
        company_params.except(:registration_number, :country).each do |key, value|
          expect(company.send(key)).to eq(value)
        end
        expect(company.country).to eq("FRA")
        expect(SharesPurchase.last.company_info.except("is_displayed")).to eq(
          company_params.stringify_keys.except("is_displayed")
        )
        expect(SharesPurchase.last.company_info["is_displayed"]).to eq("true")
      end

      it "matches existing company if possible" do
        existing_company = FactoryBot.create(:company,
          open_corporates_company_number: "891274294",
          open_corporates_jurisdiction_code: :fr)

        post api_shares_purchases_path, params: params.merge({company: company_params}), headers: headers

        expect(response.status).to eq 200
        expect(response_json).to contain_keys json_keys

        expect(Individual.count).to eq(1)
        expect(SharesPurchase.count).to eq(1)
        expect(SharesPurchase.last.company_id).to eq(existing_company.id)
      end
    end

    it "raises an error if shares_purchase already exists" do
      shares_purchase = FactoryBot.create(:shares_purchase,
        typeform_answer_uid: params[:shares_purchase][:typeform_answer_uid])

      post api_shares_purchases_path, params: params, headers: headers

      expect(response.status).to eq 400
      expect(response_json["message"]).to eq("La validation a échoué : Typeform answer uid est déjà utilisé(e)")
      expect(Individual.count).to eq(1)
      expect(Individual.pluck(:id)).to eq([shares_purchase.individual.id])
      expect(SharesPurchase.count).to eq(1)
    end

    it "neither individual nor shares_purchase is created if one of them fails" do
      params[:shares_purchase][:amount] = nil

      post api_shares_purchases_path, params: params, headers: headers

      expect(response.status).to eq 400
      expect(response_json["message"]).to eq("La validation a échoué : Amount Merci d'indiquer Amount")
      expect(Individual.count).to eq(0)
      expect(SharesPurchase.count).to eq(0)
    end
  end

  describe "show" do
    it "returns 401 if secret is not as expected" do
      get api_shares_purchase_path(typeform_answer_uid: "uid"), headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    context "returns 200 if shares_purchase is found by typeform_answer_uid" do
      it "with only typeform_answer_uid in response body if no additional fields is requested" do
        shares_purchase = FactoryBot.create(:shares_purchase, typeform_answer_uid: "typeform_answer_uid")

        get api_shares_purchase_path(typeform_answer_uid: shares_purchase.typeform_answer_uid), headers: headers
        expect(response.status).to eq 200
        expect(response_json).to eq({"typeform_answer_uid" => shares_purchase.typeform_answer_uid})
      end

      it "with requested additional fields in response body" do
        shares_purchase = FactoryBot.create(:shares_purchase, typeform_answer_uid: "typeform_answer_uid")

        get api_shares_purchase_path(
          typeform_answer_uid: shares_purchase.typeform_answer_uid,
          fields: ["payment_status"]
        ), headers: headers

        expect(response.status).to eq 200
        expect(response_json).to eq({
          "typeform_answer_uid" => shares_purchase.typeform_answer_uid,
          "payment_status" => shares_purchase.payment_status
        })
      end
    end

    it "returns 404 if individual is not found by external_uid" do
      FactoryBot.create(:shares_purchase, typeform_answer_uid: "typeform_answer_uid")

      get api_shares_purchase_path(typeform_answer_uid: "wrong-external-uid"), headers: headers
      expect(response.status).to eq 404
    end
  end

  describe "zoho sign" do
    # https://help.zoho.com/portal/en/kb/zoho-sign/admin-guide/articles/webhooks-management#Structure
    let!(:shares_purchase) { FactoryBot.create(:shares_purchase) }
    let(:params) {
      {
        "requests": {
          "request_status": "completed",
          "owner_email": "owner@time-planet.com",
          "document_ids": [
            {
              "document_name": "Template_BS_CB_PM_9L",
              "document_size": 183266,
              "document_order": "0",
              "is_editable": false,
              "total_pages": 2,
              "document_id": SecureRandom.random_number(1000).to_s
            }
          ],
          "self_sign": false,
          "owner_id": "12112295870008003",
          "request_name": "BS_CB_PM_9L (ALL)",
          "modified_time": 1669126410897,
          "action_time": 1669127256396,
          "is_deleted": false,
          "is_sequential": true,
          "owner_first_name": "Time for the Planet",
          "request_type_name": "Others",
          "owner_last_name": ".",
          "request_id": SecureRandom.random_number(1000).to_s,
          "request_type_id": SecureRandom.random_number(1000).to_s,
          "zsdocumentid": SecureRandom.uuid,
          "actions": [
            {
              "verify_recipient": false,
              "action_type": "SIGN",
              "action_id": SecureRandom.random_number(1000).to_s,
              "is_revoked": false,
              "recipient_email": "recipient@email.com",
              "is_embedded": false,
              "signing_order": 1,
              "recipient_name": "Marcel",
              "allow_signing": false,
              "recipient_phonenumber": "",
              "recipient_countrycode": "",
              "action_status": "SIGNED"
            }
          ]
        },
        "notifications": {
          # not needed for our tests
        }
      }
    }

    it "returns 401 if the user agent is not the one expected" do
      post api_sign_shares_purchase_path, headers: {"HTTP_USER_AGENT": "Wrong agent"}

      expect(response.status).to eq(401)
    end

    it "downloads documents if shares_purchase without documents associated recipient email exists" do
      updated_share = nil
      allow_any_instance_of(ZohoSign).to receive(:download_documents) do |_, share, request_id|
        updated_share = share
        true
      end
      individual = FactoryBot.create(:individual, email: params[:requests][:actions][0][:recipient_email])
      shares_purchase = FactoryBot.create(:shares_purchase, individual: individual, payment_method: :card_stripe)

      post api_sign_shares_purchase_path,
        params: params,
        headers: {"HTTP_USER_AGENT": "ZohoSign"}

      expect(response.status).to eq 200
      expect(response_json).to eq({})
      expect(updated_share).to eq shares_purchase
    end

    it "sends event to sentry if corresponding shares is not in db" do
      allow(Sentry).to receive(:capture_message).and_return("")

      post api_sign_shares_purchase_path,
        params: params,
        headers: {"HTTP_USER_AGENT": "ZohoSign"}

      expect(Sentry).to have_received(:capture_message)
    end
  end

  describe "#attach_subscription_bulletin" do
    it "returns 401 if secret is not as expected" do
      post api_attach_subscription_bulletin_path, headers: {"HTTP_AUTHORIZATION": "wrong-secret"}

      expect(response.status).to eq(401)
    end

    it "attaches the subscription bulletin" do
      shares_purchase = FactoryBot.create(:shares_purchase)
      params = {
        shares_purchase: {
          id: shares_purchase.id,
          url: "https://wallart.fr/dummy-image-2/?print=pdf"
        }
      }

      post api_attach_subscription_bulletin_path, params: params, headers: headers

      expect(response.status).to eq 200
      expect(shares_purchase.reload.subscription_bulletin.attached?).to be true
    end
  end
end
