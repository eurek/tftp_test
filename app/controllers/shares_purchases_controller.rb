class SharesPurchasesController < ApplicationController
  include SharesPurchaseGraphData

  skip_before_action :authenticate_user!, except: [:index, :remove_company_association]
  before_action :set_buy_shares_choice_cookie, except: [:buy_shares_choice, :index, :remove_company_association]
  before_action :set_current_fundraising_situation, only: [
    :become_shareholder, :become_shareholder_company, :offer_shares
  ]
  before_action :set_shares_purchases_graph_data, only: [:offer_shares_company, :use_gift_coupon]
  before_action :set_user, only: [:index]
  layout :resolve_layout

  def buy_shares_choice
    choice = params[:buy_shares_choice]
    return if choice.blank? && cookies.signed[:buy_shares_choice].blank?

    if choice.blank? && cookies.signed[:buy_shares_choice].present?
      redirect_to cookies.signed[:buy_shares_choice]
    elsif choice[:shareholder_type] == "individual" && choice[:transaction_type] == "buy"
      redirect_to become_shareholder_path
    elsif choice[:shareholder_type] == "individual" && choice[:transaction_type] == "offer"
      redirect_to offer_shares_path
    elsif choice[:shareholder_type] == "company" && choice[:transaction_type] == "buy"
      redirect_to become_shareholder_company_path
    elsif choice[:transaction_type] == "coupon"
      redirect_to use_gift_coupon_path
    else
      redirect_to offer_shares_company_path
    end
  end

  def become_shareholder
    set_top_and_recent_shareholders
    set_last_week_shareholders_count
    @future_fundings = Innovation.with_picture.on_home_in_future_funding.decorate
    @statistics = StatisticsCollecter.new.all_monthly_data
    @testimonials = Individual
      .includes(picture_attachment: :blob)
      .where(id: HighlightedContent.first&.reason_to_join_ids(fallback: false))
  end

  def become_shareholder_company
    set_top_and_recent_shareholders_companies
    @shares_purchases_by_companies_last_week = StatisticsCollecter.new.shares_purchases_by_companies_last_week
    @statistics = StatisticsCollecter.new.all_monthly_data
  end

  def offer_shares
    set_last_week_shareholders_count
  end

  def offer_shares_company
  end

  def use_gift_coupon
    set_investment_metrics
    set_top_and_recent_shareholders
  end

  def index
    @individual = current_user.individual.decorate
    @shares_purchases = current_user.individual.shares_purchases.completed.ordered_by_completed_at
    @company_shares_purchases_total = @shares_purchases.by_company.total_raised
    @individual_shares_purchases_total = @shares_purchases.by_individual.total_raised
  end

  def remove_company_association
    shares_purchase = SharesPurchase.find(params[:id])
    if shares_purchase.update(company_id: nil)
      flash[:notice] = t("private_space.investments.remove_association.success")
    else
      flash[:alert] = t("private_space.investments.remove_association.error")
    end
    redirect_to shares_purchases_path
  end

  private

  def set_top_and_recent_shareholders
    @recent_shareholders = Individual.joins(:user).last(3).reverse
    @day_top = SharesPurchase.day_top&.decorate
    @week_top = SharesPurchase.week_top&.decorate
    @year_top = SharesPurchase.year_top&.decorate
  end

  def set_top_and_recent_shareholders_companies
    @recent_shareholders_companies = Company.to_display.with_admin.last(3).reverse
    @year_top_companies = SharesPurchase.by_company.year_top&.decorate
    @all_time_top_companies = SharesPurchase.by_company.all_time_top&.decorate
    @month_top_companies = SharesPurchase.by_company.month_top&.decorate
  end

  def set_buy_shares_choice_cookie
    cookies.signed[:buy_shares_choice] = {value: request.original_url, expires: 6.months}
  end

  def set_last_week_shareholders_count
    @shares_purchases_by_citizens_last_week = StatisticsCollecter.new.shares_purchases_by_citizens_last_week
  end

  def resolve_layout
    if action_name == "index" && current_user.pending?
      "onboarding"
    elsif action_name == "index"
      "private_space"
    else
      "static"
    end
  end

  def set_investment_metrics
    @last_done_short_tasks = RoadmapTask.where(duration_type: "short").done.last(4)
    @revealed_badges = Badge.where(id: Badge::BECOME_SHAREHOLDER_BADGE_IDS)
  end

  def set_current_fundraising_situation
    @current_situation = CurrentSituation.first
    @total_raised = SharesPurchase.total_raised
    @current_episode = Episode.current.decorate
  end
end
