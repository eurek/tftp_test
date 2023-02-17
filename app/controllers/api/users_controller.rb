class Api::UsersController < Api::ApiController
  def update_badges
    individual = Individual.find_by(email: params[:individual][:email])
    return head :not_found if individual.nil?

    badges = Badge.where(external_uid: individual_badges_params[:badge_external_uids])
    individual.update!(badges: badges)
    head :no_content
  end

  def update_roles
    individual = Individual.find_by(email: params[:individual][:email])
    return head :not_found if individual.nil?

    roles = Role.where(external_uid: individual_roles_params[:role_external_uids])
    individual.update!(roles: roles)
    head :no_content
  end

  def show
    fields = params[:fields] || []
    individual = Individual.find_by_external_uid(params[:external_uid])
    return head :not_found if individual.nil?
    render json: individual.slice(:external_uid, *fields), status: :ok
  end

  def missing
    external_uids = params[:external_uids]
    saved_individuals_uids = Individual.where(external_uid: external_uids).pluck(:external_uid) || []
    unsaved_individuals_uids = params[:external_uids] - saved_individuals_uids
    render json: unsaved_individuals_uids, status: :ok
  end

  private

  def individual_update_params
    params.require(:user).permit(:external_uid, :email, :address, :zip_code, :country)
  end

  def individual_params
    params.require(:user).permit(:external_uid, :email, :first_name, :last_name, :phone, :address, :zip_code,
      :city, :country, :date_of_birth)
  end

  def shares_purchase_params
    params.require(:shares_purchase).permit(:external_uid, :amount, :completed_at, :temporary_company_name)
  end

  def individual_badges_params
    params.require(:individual).permit(badge_external_uids: [])
  end

  def individual_roles_params
    params.require(:individual).permit(role_external_uids: [])
  end
end
