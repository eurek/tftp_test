class Api::ApiController < ApplicationController
  skip_around_action :switch_locale
  skip_before_action :verify_authenticity_token, :authenticate_user!, :set_navbar_menu_links, :set_footer_links,
    :set_external_links
  before_action :authenticate_api!, :set_locale_to_fr

  rescue_from ActionController::ParameterMissing, with: :render_error
  rescue_from ActiveRecord::RecordInvalid, with: :render_error

  def render_error_message(message, status = :bad_request)
    json = {
      message: message
    }
    render json: json, status: status
  end

  protected

  def create_or_update_individual
    individual = Individual.find_or_initialize_by(email: params[:individual][:email])
    individual.update!(individual_params)
    individual
  end

  def company_params
    params.require(:company).permit(:name, :address, :is_displayed, :country, :legal_form, :structure_size,
      :city, :zip_code, :street_address, :registration_number, :website)
  end

  def individual_params
    params.require(:individual).permit(:external_uid, :email, :first_name, :last_name, :phone, :address, :zip_code,
      :city, :country, :date_of_birth, :communication_language, :nationality, :is_100_club, :id_card_received,
      :stacker_role, :is_displayed, :username, :origin)
  end

  def render_error(e = nil)
    case e
    when nil?
      render_error_message(nil)
    when ActionController::ParameterMissing
      render_error_message("Missing parameter: #{e&.param}")
    else
      render_error_message(e.message)
    end
  end

  def authenticate_api!
    secret = Rails.application.credentials.dig(:external_api_secret)
    head :unauthorized unless request.headers.fetch("HTTP_AUTHORIZATION", nil) == secret
  end

  def set_locale_to_fr
    I18n.locale = "fr"
  end
end
