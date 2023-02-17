class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, only: [:update]

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [individual_attributes: [:id, :email]])
  end

  def after_update_path_for(resource)
    if resource.is_a? User
      user_dashboard_path
    end
  end
end
