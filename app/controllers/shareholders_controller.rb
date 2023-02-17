class ShareholdersController < ApplicationController
  skip_before_action :authenticate_user!
  layout "static"

  def index
    @shareholders = ShareholdersSearch.search_shareholders(
      term: params[:search],
      page: params[:page]&.to_i || 1,
      badge_ids: params.dig(:filters, :badges)&.reject(&:empty?)&.map(&:to_i) || [],
      role_ids: params.dig(:filters, :roles)&.reject(&:empty?)&.map(&:to_i) || [],
      types: params.dig(:filters, :types)&.reject(&:empty?)&.map(&:to_sym) || [],
      countries: params.dig(:filters, :countries)&.reject(&:empty?)&.map(&:to_sym) || [],
      limit: 40
    )
    @countries_codes = (
      Individual.to_display.pluck(:country) + Company.to_display.pluck(:country)
    ).uniq.compact

    @types_collection = [
      [t("shareholder.index.filters.type_individual"), :individual],
      [t("shareholder.index.filters.type_company"), :company]
    ]
    @total_accounts = @shareholders.total_accounts
    @badges = Badge.joins(picture_light_attachment: :blob)
  end

  def map
    @markers = Rails.cache.fetch("shareholders_map_markers", expires_in: 1.day) do
      sql = "(#{Individual.joins(:user).geocoded.select(:latitude, :longitude).to_sql}) UNION ALL"\
            "(#{Company.geocoded.select(:latitude, :longitude).to_sql})"
      shareholders = ApplicationRecord.connection.select_all(sql).rows
      shareholders.map do |shareholder|
        {
          lat: shareholder[0],
          lng: shareholder[1]
        }
      end
    end
  end

  def show_individual
    @scope = Individual.includes(:roles, :badges, picture_attachment: :blob)
    # TODO: Remove .find when google has indexed new urls
    @shareholder = @scope.find_by_slug(params[:slug]) || @scope.joins(:user).find_by!("users.id": params[:slug])
    return redirect_to shareholders_path unless @shareholder.is_displayed

    fullpath = shareholder_individual_show_path(@shareholder)
    redirect_to fullpath, status: :moved_permanently if request.path != fullpath
  end

  def show_company
    @company = Company.find_by_slug(params[:slug]) || Company.find(params[:slug])
    unless @company.is_displayed && (@company.admin.present? || @company.creator.present?)
      return redirect_to shareholders_path
    end

    @shareholder_employees = @company.employees.includes(
      :roles,
      picture_attachment: :blob,
      badges: {picture_light_attachment: :blob}
    ).where(is_displayed: true)

    fullpath = shareholder_company_show_path(@company)
    redirect_to fullpath, status: :moved_permanently if request.path != fullpath
  end
end
