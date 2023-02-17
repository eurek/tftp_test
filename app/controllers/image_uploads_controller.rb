class ImageUploadsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token
  skip_around_action :switch_locale
  before_action :authenticate_admin_user!

  def create
    object = model_params[:model].constantize.find(model_params[:id])
    attribute = (model_params[:attribute] + "_attachments").to_sym
    number_of_files = file_params.length

    object.send(attribute).attach(file_params)
    attachments = object.send(attribute).attachments.last(number_of_files)

    json = attachments.map.with_index do |attachment, index|
      [
        "file-#{index}",
        {
          id: attachment.id,
          url: url_for(attachment)
        }
      ]
    end.to_h

    render json: json, status: :ok
  end

  def destroy
    ActiveStorage::Attachment.find(params[:attachment_id])&.purge
    head :no_content
  end

  private

  def model_params
    keys = [:model, :id, :attribute]
    params.require(keys)
    params.permit(keys)
  end

  def file_params
    params.require(:file)
  end
end
