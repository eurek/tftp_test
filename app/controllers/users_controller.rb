class UsersController < ApplicationController
  layout :resolve_layout
  before_action :set_user_and_individual
  include CompanyFinder

  def edit_profile
    set_employer
  end

  def update
    is_update_successful = @individual.update(individual_params)
    is_company_new = @user.individual.employer.present? &&
      params.dig(:individual, :employer_attributes, :id).blank?

    @individual.employer.update(creator_id: @user.id) if is_company_new && is_update_successful

    if is_update_successful && !@user.pending?
      flash[:notice] = t("private_space.dashboard.profile_updated")
      redirect_to user_dashboard_path
    elsif is_update_successful
      redirect_to finish_onboarding_path
    else
      set_employer
      render :edit_profile
    end
  end

  def dashboard
    return redirect_to user_profile_path if @user.pending?

    @last_done_task = RoadmapTask.done.last
    @current_situation = CurrentSituation.first
    @current_episode = Episode.current.decorate
  end

  def finish_onboarding
    @user.update(pending: false)
    flash[:notice] = t("private_space.dashboard.welcome")
    redirect_to user_dashboard_path
  end

  def badges
    @badges = @individual.badges
  end

  def delete_profile_picture
    @picture = current_user.individual.picture
    @picture.purge
    flash[:notice] = t("common.file_deleted")
    redirect_to user_profile_path
  end

  def assign_employer
    @company = find_or_initialize_company(company_params)
    @company.save
    @individual.update(employer: @company)
    redirect_to user_profile_path
  end

  def remove_employer
    @individual.update(employer: nil)
    redirect_to user_profile_path
  end

  private

  def set_user_and_individual
    @user = current_user
    @individual = current_user.individual.decorate
  end

  def set_employer
    @employer = @individual.employer || @individual.build_employer
    @is_company_editable = (@employer.new_record? || @employer.creator == @user) && @employer.admin.blank?
    @company_card_partial = render_to_string partial: "shared/company_info_card", locals: {company: Company.new}
  end

  def individual_params
    params.require(:individual).permit(
      :is_displayed,
      :picture,
      :description,
      :current_job,
      :reasons_to_join,
      :first_name,
      :last_name,
      :country, :city,
      :date_of_birth,
      employer_attributes: [:id, :name, :address]
    )
  end

  def password_params
    params.require(:user).permit(
      :password,
      :password_confirmation,
      :current_password
    )
  end

  def resolve_layout
    if current_user.pending
      "onboarding"
    else
      "private_space"
    end
  end
end
