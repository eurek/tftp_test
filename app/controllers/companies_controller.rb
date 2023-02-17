class CompaniesController < ApplicationController
  layout :resolve_layout
  before_action :set_edit_form, only: [:edit, :update]
  before_action :set_user, only: [:new, :create, :choose, :select_as_shareholder, :edit, :index]
  include CompanyFinder

  def new
    redirect_to shares_purchases_path unless shares_purchase_by_company?

    if params.dig(:company, :name).present?
      @previous_search = params[:company][:name]
      @company = Company.new(name: @previous_search)
    else
      @company = Company.new
    end
    @shares_purchase_id = params[:shares_purchase_id] if params[:shares_purchase_id].present?
  end

  def create
    redirect_to shares_purchases_path unless shares_purchase_by_company?

    @company = Company.new(full_company_params)
    @company.admin = @user
    assign_shares_purchase_to_company if params[:shares_purchase_id].present?

    if @company.save && @shares_purchase.save
      current_user.individual.update(employer_id: @company.id)
      redirect_to shares_purchases_path
    else
      @shares_purchase_id = params[:shares_purchase_id]
      render :new
    end
  end

  def choose
    @is_employer_step = params[:employer].present?
    @individual = current_user.individual.decorate
    @pending = current_user.pending?
    @new_company_name = params.dig(:search, :name)
    @shares_purchase_id = params[:shares_purchase_id]
    @shares_purchase = SharesPurchase.find(@shares_purchase_id) if @shares_purchase_id.present?

    @companies = if params[:search].present? && params[:search][:name].present?
      Company.autocomplete_suggestions(
        params[:search][:name],
        ActiveModel::Type::Boolean.new.cast(params[:search][:exact])
      )
    else
      []
    end
  end

  def select_as_shareholder
    @company = find_or_initialize_company(company_params)
    @company.admin = @user if @company.admin.blank?
    assign_shares_purchase_to_company

    unless @company.save && @shares_purchase.save
      flash[:alert] = t("private_space.choose_company.error")
      return redirect_to choose_company_path(search: search_params, shares_purchase_id: params[:shares_purchase_id])
    end

    if @company.admin == @user
      redirect_to edit_company_path(
        id: @company.id,
        shares_purchase_id: @shares_purchase.id,
        previous_search: params[:search][:name]
      )
    else
      redirect_to shares_purchases_path
    end
  end

  def edit
    redirect_to shares_purchases_path unless @is_current_user_admin

    @shares_purchase_id = params[:shares_purchase_id]
    @previous_search = params[:previous_search]
  end

  def update
    redirect_to shares_purchases_path unless @is_current_user_admin

    is_update_successful = @company.update(full_company_params)
    if is_update_successful
      flash[:notice] = t("private_space.edit_company.success")
      redirect_to appropriate_path_after_update

    else
      render :edit
    end
  end

  def index
    @companies = Company.where(admin: @user)

    redirect_to user_dashboard_path if @companies.empty?
  end

  def delete_logo
    company = Company.find(params[:id])

    if current_user == company.admin
      company.logo.purge
      flash[:notice] = t("common.file_deleted")
      redirect_to edit_company_path(id: company.id)
    else
      flash[:notice] = t("common.cant_delete_file")
      redirect_to user_dashboard_path
    end
  end

  private

  def set_edit_form
    @company = Company.find(params[:id])
    @is_current_user_admin = @company&.admin == current_user
    @pending = current_user.pending?
  end

  def full_company_params
    params.require(:company).permit(
      :is_displayed,
      :name,
      :address,
      :logo,
      :description,
      :co2_emissions_reduction_actions,
      :website,
      :facebook,
      :linkedin
    )
  end

  def search_params
    params.require(:search).permit(
      :name,
      :exact
    )
  end

  def assign_shares_purchase_to_company
    @shares_purchase = SharesPurchase.find(params[:shares_purchase_id])
    @shares_purchase.company = @company
  end

  def shares_purchase_by_company?
    return false unless params[:shares_purchase_id].present?

    SharesPurchase.find_by(id: params[:shares_purchase_id])&.company_info.present?
  end

  def resolve_layout
    if current_user.pending
      "onboarding"
    else
      "private_space"
    end
  end

  def appropriate_path_after_update
    if params[:company][:from_companies_index] == "true"
      companies_path
    else
      shares_purchases_path
    end
  end
end
