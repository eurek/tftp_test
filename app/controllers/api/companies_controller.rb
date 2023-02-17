class Api::CompaniesController < Api::ApiController
  def update_badges
    company = Company.find_by(id: params[:id])
    return head :not_found if company.nil?

    badges = Badge.where(external_uid: company_badges_params[:badge_external_uids])
    company.update!(badges: badges)
    head :no_content
  end

  def update_roles
    company = Company.find_by(id: params[:id])
    return head :not_found if company.nil?

    roles = Role.where(external_uid: company_roles_params[:role_external_uids])
    company.update!(roles: roles)
    head :no_content
  end

  private

  def company_badges_params
    params.require(:company).permit(badge_external_uids: [])
  end

  def company_roles_params
    params.require(:company).permit(role_external_uids: [])
  end
end
