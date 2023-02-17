require "rails_helper"

describe ZohoSign do
  describe "#generate_token" do
    it "generates a token given the required credentials sent in url encoded form" do
      expected_params = {
        client_id: Rails.application.credentials.dig(:zohosign, :client_id),
        client_secret: Rails.application.credentials.dig(:zohosign, :client_secret),
        refresh_token: Rails.application.credentials.dig(:zohosign, :refresh_token),
        grant_type: "refresh_token"
      }.map { |k, v| "#{k}=#{v}" }.join("&")

      stub = stub_request(:post, ZohoSign::AUTH_URL)
        .with(
          body: expected_params,
          headers: {"Content-Type" => "application/x-www-form-urlencoded", "charset" => "utf-8"}
        )
        .to_return(
          status: 200,
          body: {access_token: "token"}.to_json,
          headers: {"Content-Type" => "application/json"}
        )

      expect(ZohoSign.new.send(:generate_token)).to eq "token"
      expect(stub).to have_been_requested
    end

    let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
    let(:cache) { Rails.cache }
    it "keeps it for 60 min" do
      stub_request(:post, ZohoSign::AUTH_URL)
        .to_return(
          status: 200,
          body: {access_token: "token"}.to_json,
          headers: {"Content-Type" => "application/json"}
        )

      allow(Rails).to receive(:cache).and_return(memory_store)
      cache.clear
      expect(cache.exist?("zohosign-token")).to be(false)

      ZohoSign.new.send(:generate_token)
      expect(cache.exist?("zohosign-token")).to be(true)

      # expires after 30min
      Timecop.freeze(Time.now + 60.minutes) do
        expect(cache.exist?("zohosign-token")).to be(false)

        ZohoSign.new.send(:generate_token)
        expect(cache.exist?("zohosign-token")).to be(true)
      end
    end
  end

  describe "#download_documents" do
    before(:each) do
      @token_stub = stub_request(:post, ZohoSign::AUTH_URL)
        .to_return(
          status: 200,
          body: {access_token: "token"}.to_json,
          headers: {"Content-Type" => "application/json"}
        )
    end

    it "downloads the signed document and its certificate to the given share purchase" do
      shares_purchase = FactoryBot.create(:shares_purchase)
      zoho_request_id = "request_id"

      bulletin = File.open("spec/support/assets/bulletin.pdf")
      bulletin_checksum = Digest::MD5.file("spec/support/assets/bulletin.pdf").base64digest

      certificate = File.open("spec/support/assets/certificate.pdf")
      certificate_checksum = Digest::MD5.file("spec/support/assets/certificate.pdf").base64digest

      stub_request(:get, "#{ZohoSign.base_uri}/requests/#{zoho_request_id}/pdf")
        .with(headers: {"Authorization" => "Zoho-oauthtoken token"})
        .to_return(
          status: 200,
          body: bulletin
        )

      stub_request(:get, "#{ZohoSign.base_uri}/requests/#{zoho_request_id}/completioncertificate")
        .with(headers: {"Authorization" => "Zoho-oauthtoken token"})
        .to_return(
          status: 200,
          body: certificate
        )

      ZohoSign.new.send(:download_documents, shares_purchase, zoho_request_id)

      expect(shares_purchase.subscription_bulletin.blob.checksum).to eq bulletin_checksum
      expect(shares_purchase.subscription_bulletin_certificate.blob.checksum).to eq certificate_checksum
    end

    it "generates a new token and retry downloading if unauthorized" do
      shares_purchase = FactoryBot.create(:shares_purchase)
      zoho_request_id = "request_id"

      bulletin = File.open("spec/support/assets/bulletin.pdf")
      bulletin_checksum = Digest::MD5.file("spec/support/assets/bulletin.pdf").base64digest

      certificate = File.open("spec/support/assets/certificate.pdf")
      certificate_checksum = Digest::MD5.file("spec/support/assets/certificate.pdf").base64digest

      stub_request(:get, "#{ZohoSign.base_uri}/requests/#{zoho_request_id}/pdf")
        .with(headers: {"Authorization" => "Zoho-oauthtoken token"})
        .to_return({
          status: 401,
          body: {"error": "invalid_token"}.to_json
        }, {
          status: 200,
          body: bulletin
        })

      stub_request(:get, "#{ZohoSign.base_uri}/requests/#{zoho_request_id}/completioncertificate")
        .with(headers: {"Authorization" => "Zoho-oauthtoken token"})
        .to_return(
          status: 200,
          body: certificate
        )

      ZohoSign.new.send(:download_documents, shares_purchase, zoho_request_id)

      expect(@token_stub).to have_been_requested.twice
      expect(shares_purchase.subscription_bulletin.blob.checksum).to eq bulletin_checksum
      expect(shares_purchase.subscription_bulletin_certificate.blob.checksum).to eq certificate_checksum
    end

    it "retries once then reports errors to Sentry" do
      shares_purchase = create(:shares_purchase)
      zoho_request_id = "request_id"

      stub_request(:get, "#{ZohoSign.base_uri}/requests/#{zoho_request_id}/pdf")
        .with(headers: {"Authorization" => "Zoho-oauthtoken token"})
        .to_return(
          status: 401,
          body: {"error": "invalid_token"}.to_json
        )

      sentry_params = {}
      allow(Sentry).to receive(:capture_message) do |message, **params|
        sentry_params[:message] = message
        sentry_params[:params] = params
      end

      ZohoSign.new.send(:download_documents, shares_purchase, zoho_request_id)
      expect(@token_stub).to have_been_requested.twice
      expect(sentry_params[:message]).to eq "Couldn't download subscription bulletin"
      expect(sentry_params.dig(:params, :extra, :error).as_json).to eq "401 "
      expect(sentry_params.dig(:params, :extra, :individual).as_json).to eq shares_purchase.individual_id
    end
  end

  def generate_request_payload(action, status, document, email, action_time = 1669127256396)
    {
      "request_status": "completed",
      "owner_email": "owner@time-planet.com",
      "document_ids": [
        {
          "document_name": "Template_#{document}",
          "document_size": 183266,
          "document_order": "0",
          "is_editable": false,
          "total_pages": 2,
          "document_id": SecureRandom.random_number(1000).to_s
        }
      ],
      "self_sign": false,
      "owner_id": "12112295870008003",
      "request_name": document,
      "modified_time": 1669126410897,
      "action_time": action_time,
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
          "action_type": action,
          "action_id": SecureRandom.random_number(1000).to_s,
          "is_revoked": false,
          "recipient_email": email,
          "is_embedded": false,
          "signing_order": 1,
          "recipient_name": "Marcel",
          "allow_signing": false,
          "recipient_phonenumber": "",
          "recipient_countrycode": "",
          "action_status": status
        }
      ]
    }
  end

  def generate_webhook_payload(action, status, document, email)
    {
      "requests": generate_request_payload(action, status, document, email),
      "notifications": {
        # not needed for our tests
      }
    }
  end

  def generate_document_list(documents)
    requests = documents.map do |d|
      generate_request_payload(d[:action], d[:status], d[:document], d[:email], d[:action_time])
    end
    {
      "requests": requests,
      "message": "Document list retrieved successfully",
      "page_context": {
        "sort_column": "created_time",
        "has_more_rows": false,
        "start_index": 1,
        "total_count": 2,
        "sort_order": "DESC",
        "row_count": 2
      },
      "status": "success"
    }
  end

  describe "handle_sign_webhook" do
    before(:each) do
      context = self
      allow_any_instance_of(ZohoSign).to receive(:download_documents) do |_, share, request_id|
        context.instance_variable_set(:@zoho_share, share)
        true
      end
    end

    it "makes sure we're handling a signed document event or a document sent event" do
      payload = generate_webhook_payload(
        "UNKNOWN", "UNKNOWN", "doc", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "unknown_type"

      payload = generate_webhook_payload(
        "UNKNOWN", "SIGNED", "doc", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "unknown_type"

      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "doc", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "not_a_bulletin"

      payload = generate_webhook_payload(
        "SIGN", "UNOPENED", "doc", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "not_a_bulletin"
    end

    it "makes sure the document is a subscription bulletin" do
      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "doc", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "not_a_bulletin"

      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "Charte evaluateurs (EN)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "not_a_bulletin"

      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "BS_CB_PM_9L (ALL)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "no_individual"
    end

    it "finds the associated individual" do
      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "BS_CB_PM_9L (ALL)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "no_individual"

      FactoryBot.create(:individual, email: "user@join-time.com")
      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "BS_CB_PM_9L (ALL)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "no_shares"
    end

    it "finds the associated share purchase" do
      individual = FactoryBot.create(:individual, email: "user@join-time.com")
      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "BS_CB_PM_9L (ALL)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "no_shares"

      FactoryBot.create(
        :shares_purchase, individual: individual,
        subscription_bulletin: {io: File.open("spec/support/assets/bulletin.pdf"), filename: "bulletin.pdf"}
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "no_shares"

      FactoryBot.create(:shares_purchase, individual: individual, payment_method: :transfer_ce)
      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "BS_CB_PM_9L (ALL)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq "no_shares"

      FactoryBot.create(:shares_purchase, individual: individual, payment_method: :card_stripe)
      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "BS_CB_PM_9L (ALL)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq true

      FactoryBot.create(:shares_purchase, individual: individual, payment_method: :gift_coupon)
      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "BS_CB_PM_9L (ALL)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq true
    end

    it "saves request_id on the most recent share that doesn't have bulletins" do
      individual = FactoryBot.create(:individual, email: "user@join-time.com")
      share_without_doc = FactoryBot.create(:shares_purchase, individual: individual, payment_method: :transfer_ce)
      FactoryBot.create(
        :shares_purchase, individual: individual,
        subscription_bulletin: {io: File.open("spec/support/assets/bulletin.pdf"), filename: "bulletin.pdf"}
      )

      payload = generate_webhook_payload(
        "SIGN", "UNOPENED", "BS_VIR_PM_9L (ALL)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to be nil
      expect(share_without_doc.reload.zoho_sign_request_id).to eq(payload.dig(:requests, :request_id))
    end

    it "starts downloading documents on the most recent share that doesn't have bulletins" do
      individual = FactoryBot.create(:individual, email: "user@join-time.com")
      share_without_doc = FactoryBot.create(:shares_purchase, individual: individual, payment_method: :card_stripe)
      FactoryBot.create(
        :shares_purchase, individual: individual,
        subscription_bulletin: {io: File.open("spec/support/assets/bulletin.pdf"), filename: "bulletin.pdf"}
      )

      payload = generate_webhook_payload(
        "SIGN", "SIGNED", "BS_CB_PM_9L (ALL)", "user@join-time.com"
      )
      expect(ZohoSign.new.handle_sign_webhook(payload)).to eq true
      expect(@zoho_share).to eq share_without_doc
    end
  end

  describe "#documents_list_for" do
    before(:each) do
      @token_stub = stub_request(:post, ZohoSign::AUTH_URL)
        .to_return(
          status: 200,
          body: {access_token: "token"}.to_json,
          headers: {"Content-Type" => "application/json"}
        )
    end

    it "make request with expected params and returns parsed_response" do
      @documents = File.open(Rails.root.join("spec/mocks/zoho/document_list_for_recipient_email.json")).read
      expected_params = {
        page_context:
          {
            row_count: 20,
            start_index: 1,
            search_columns: {recipient_email: "example@email.com"},
            sort_column: "created_time",
            sort_order: "DESC"
          }
      }.to_json
      stub = stub_request(:get, "#{ZohoSign.base_uri}/requests?data=#{CGI.escape(expected_params)}")
        .with(headers: {"Authorization" => "Zoho-oauthtoken token"})
        .to_return(
          status: 200,
          headers: {"Content-Type" => "application/json"},
          body: @documents
        )

      response = ZohoSign.new.send(:documents_list_for, "example@email.com")

      expect(stub).to have_been_requested
      expect(response).to eq(JSON.parse(@documents, {symbolize_names: true}))
    end
  end

  describe "#unique_signed_bulletin" do
    before(:each) do
      @token_stub = stub_request(:post, ZohoSign::AUTH_URL)
        .to_return(
          status: 200,
          body: {access_token: "token"}.to_json,
          headers: {"Content-Type" => "application/json"}
        )
      @documents = File.open(Rails.root.join("spec/mocks/zoho/document_list_for_recipient_email.json")).read
    end

    it "returns zoho document if it is the only signed one for this email recipient" do
      @documents = generate_document_list([
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com"},
        {action: "SIGN", status: "DECLINED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com"}
      ])
      stub = stub_request(:get, /#{Regexp.quote(ZohoSign.base_uri)}/)
        .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: @documents.to_json)

      bulletin = ZohoSign.new.unique_signed_bulletin("example@email.com")

      expect(stub).to have_been_requested
      expect(bulletin).to eq(@documents[:requests][0])
    end

    it "returns a message if there is no signed BS" do
      @documents = generate_document_list([
        {action: "SIGN", status: "SIGNED", document: "Charte RGPD (FR)", email: "user@join-time.com"},
        {action: "SIGN", status: "DECLINED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com"}
      ])
      stub = stub_request(:get, /#{Regexp.quote(ZohoSign.base_uri)}/)
        .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: @documents.to_json)

      bulletin = ZohoSign.new.unique_signed_bulletin("example@email.com")

      expect(stub).to have_been_requested
      expect(bulletin).to eq("no signed bulletin")
    end

    it "returns a message if there is more than one signed BS" do
      @documents = generate_document_list([
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com"},
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com"}
      ])
      stub = stub_request(:get, /#{Regexp.quote(ZohoSign.base_uri)}/)
        .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: @documents.to_json)

      bulletin = ZohoSign.new.unique_signed_bulletin("example@email.com")

      expect(stub).to have_been_requested
      expect(bulletin).to eq("more than one signed bulletin")
    end
  end

  describe "#unique_signed_bulletin_around" do
    before(:each) do
      @token_stub = stub_request(:post, ZohoSign::AUTH_URL)
        .to_return(
          status: 200,
          body: {access_token: "token"}.to_json,
          headers: {"Content-Type" => "application/json"}
        )
    end

    it "returns zoho document if it is the only signed one for this email recipient around this date" do
      completed_at = DateTime.parse("2022-12-31 12:00")
      @documents = generate_document_list([
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com",
         action_time: (completed_at - 23.hours).to_i * 1000},
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com",
         action_time: (completed_at - 25.hours).to_i * 1000},
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com",
         action_time: (completed_at + 2.hours).to_i * 1000}
      ])
      stub_request(:get, /#{Regexp.quote(ZohoSign.base_uri)}/)
        .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: @documents.to_json)

      bulletin = ZohoSign.new.unique_signed_bulletin_around(
        "example@email.com",
        completed_at - 24.hours,
        completed_at + 1.hour,
        "card_stripe"
      )

      expect(bulletin).to eq(@documents[:requests][0])
    end

    it "returns a message if there is no signed BS matching all filters" do
      completed_at = DateTime.parse("2022-12-31 12:00")
      @documents = generate_document_list([
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com",
         action_time: (completed_at - 25.hours).to_i * 1000},
        {action: "SIGN", status: "SIGNED", document: "Charte RGPD (FR)", email: "user@join-time.com",
         action_time: (completed_at - 23.hours).to_i * 1000},
        {action: "SIGN", status: "VIEWED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com",
         action_time: (completed_at - 23.hours).to_i * 1000},
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com",
         action_time: (completed_at + 2.hours).to_i * 1000},
        {action: "SIGN", status: "SIGNED", document: "BS_VIR_PM_9L (FR)", email: "user@join-time.com",
         action_time: (completed_at - 23.hours).to_i * 1000}
      ])
      stub_request(:get, /#{Regexp.quote(ZohoSign.base_uri)}/)
        .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: @documents.to_json)

      bulletin = ZohoSign.new.unique_signed_bulletin_around(
        "example@email.com",
        completed_at - 24.hours,
        completed_at + 1.hour,
        "card_stripe"
      )

      expect(bulletin).to eq("no signed bulletin")
    end

    it "returns a message if there is more than one signed BS" do
      completed_at = DateTime.parse("2022-12-31 12:00")
      @documents = generate_document_list([
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com",
         action_time: (completed_at - 22.hours).to_i * 1000},
        {action: "SIGN", status: "SIGNED", document: "BS_CB_PM_9L (FR)", email: "user@join-time.com",
         action_time: (completed_at - 23.hours).to_i * 1000}
      ])
      stub_request(:get, /#{Regexp.quote(ZohoSign.base_uri)}/)
        .to_return(status: 200, headers: {"Content-Type" => "application/json"}, body: @documents.to_json)

      bulletin = ZohoSign.new.unique_signed_bulletin_around(
        "example@email.com",
        completed_at - 24.hours,
        completed_at + 1.hour,
        "card_stripe"
      )

      expect(bulletin).to eq("more than one signed bulletin")
    end
  end
end
