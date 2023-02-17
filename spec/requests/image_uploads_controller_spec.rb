require "rails_helper"

describe "Image Uploads" do
  describe "create" do
    it "redirects if request is not authenticated" do
      post image_upload_path, params: {}

      expect(response.status).to eq 302
      expect(response).to redirect_to(new_admin_user_session_path)
    end

    it "can upload one file" do
      sign_in_as_admin
      content = FactoryBot.create(:content, status: "published", body: nil)

      body_attachment = Rack::Test::UploadedFile.new("spec/support/assets/resume.png", "image/png")
      params = {
        model: content.class,
        id: content.id,
        attribute: :body,
        file: [body_attachment]
      }
      post image_upload_path, params: params

      expect(response.status).to eq 200
      expect(response.body).to eq(
        {"file-0": {id: ActiveStorage::Attachment.last.id, url: url_for(ActiveStorage::Attachment.last)}}.to_json
      )
    end

    it "can upload multiple files" do
      sign_in_as_admin
      content = FactoryBot.create(:content, status: "published", body: nil)

      attachment_1 = Rack::Test::UploadedFile.new("spec/support/assets/resume.png", "image/png")
      attachment_2 = Rack::Test::UploadedFile.new(
        "spec/support/assets/picture-profile.jpg",
        "image/jpg"
      )
      params = {
        model: content.class,
        id: content.id,
        attribute: :body,
        file: [attachment_1, attachment_2]
      }
      post image_upload_path, params: params

      attachments = ActiveStorage::Attachment.last(2)
      expect(response.status).to eq 200
      expect(response.body).to eq({
        "file-0": {id: attachments[0].id, url: url_for(attachments[0])},
        "file-1": {id: attachments[1].id, url: url_for(attachments[1])}
      }.to_json)
    end

    it "raise 400 if model param is missing" do
      sign_in_as_admin
      params = {
        model: "Content",
        attribute: :body,
        file: []
      }

      expect { post image_upload_path, params: params }.to raise_error(ActionController::ParameterMissing)
    end

    it "raise 400 if id param is missing" do
      sign_in_as_admin
      params = {
        model: "Content",
        attribute: :body,
        file: []
      }

      expect { post image_upload_path, params: params }.to raise_error(ActionController::ParameterMissing)
    end

    it "raise 400 if attribute param is missing" do
      sign_in_as_admin
      params = {
        model: "Content",
        id: "some-id",
        file: []
      }

      expect { post image_upload_path, params: params }.to raise_error(ActionController::ParameterMissing)
    end

    it "raise 400 if file param is missing" do
      sign_in_as_admin
      content = FactoryBot.create(:content, status: "published", body: nil)
      params = {
        model: content.class,
        id: content.id,
        attribute: :body
      }

      expect { post image_upload_path, params: params }.to raise_error(ActionController::ParameterMissing)
    end

    it "raise 404 if employee article doesn't exist" do
      sign_in_as_admin
      params = {
        model: "Content",
        id: "wrong-id",
        attribute: :body,
        file: []
      }

      expect { post image_upload_path, params: params }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "destroy" do
    it "redirects if request is not authenticated" do
      delete image_upload_path

      expect(response.status).to eq 302
      expect(response).to redirect_to(new_admin_user_session_path)
    end

    it "deletes attachment" do
      sign_in_as_admin
      content = FactoryBot.create(:content, status: "published", body_i18n: {})
      content.body_attachments.attach(
        io: File.open(Rails.root.join("spec/support/assets/resume.png")), filename: "resume.png"
      )

      delete image_upload_path, params: {attachment_id: content.reload.body_attachments.first.id}

      expect(response.status).to eq 204
      expect(ActiveStorage::Attachment.count).to eq(0)
      expect(ActiveStorage::Blob.count).to eq(0)
      expect(content.reload.body_attachments).not_to be_present
    end

    it "raise 404 if employee article doesn't exist" do
      sign_in_as_admin

      params = {attachment_id: "wrong_id"}

      expect { delete image_upload_path, params: params }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
