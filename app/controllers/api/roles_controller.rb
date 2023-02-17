class Api::RolesController < Api::ApiController
  def create
    role = Role.find_or_initialize_by(external_uid: role_params[:external_uid])
    role.update!(role_params)
    render json: role.as_json, status: :ok
  end

  private

  def role_params
    params.require(:role).permit(:external_uid, :name, :description, :position, :attributable_to)
  end
end
