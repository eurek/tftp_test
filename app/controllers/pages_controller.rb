class PagesController < ApplicationController
  include SharesPurchaseGraphData

  skip_before_action :authenticate_user!
  layout "static", except: :connection

  def home
    set_home_variables
    if params.dig(:ambassador).present?
      user = Individual.find_by_slug(params.dig(:ambassador))&.user
      user&.update(generated_visits: user.generated_visits + 1)
      user && AutopilotAmbassadorPusherJob.perform_later(user.id)
    end
    set_home_choice_cookie("individual")
    episodes = Episode.past_and_current.ordered_by_season
    @recent_episodes = episodes.decorate.last(3)
    @first_episode = episodes.first
    # TODO FundedInnovation.sum("CAST(co2_reduction -> '2022' AS NUMERIC)").to_i here
    @total_co2_2022 = FundedInnovation.pluck(:co2_reduction).map { |co2_values| co2_values.try("2022").to_i }.sum
  end

  def company_home
    set_home_variables
    @shareholder_companies_count = SharesPurchase.by_company.count
    @links = {
      investment_brief: custom_content_path(Content.find(Content::INVESTMENT_BRIEF_ID)),
      press_kit: custom_content_path(Content.find(Content::PRESS_KIT_ID)),
      open_source: custom_content_path(Content.find(Content::OPEN_SOURCE_FILE_ID)),
      greenwashing: custom_content_path(Content.find(Content::GREENWASHING_FILE_ID)),
      climate_dividends: "https://www.climate-dividends.com/",
      founders: shareholders_path(filters: {roles: [Role.find(Role::FOUNDER_ID)]}),
      supervisory_board: shareholders_path(filters: {roles: [Role.find(Role::SUPERVISORY_BOARD_ID)]}),
      scientific_commitee: shareholders_path(filters: {role: [Role.find(Role::SCIENTIFIC_COMMITEE_ID)]})
    }
    set_home_choice_cookie("company")
  end

  def vision
  end

  def show
    @page = Page.find_by(slug: params[:slug])
  end

  def ambassador_landing
    @influencers ||= YAML.load_file("#{Rails.root}/config/influencers.yml")
    if @influencers.key?(params[:ambassador_slug])
      return redirect_to "#{root_path}?#{@influencers[params[:ambassador_slug]]}"
    end

    individual = Individual.find_by(public_slug: params[:ambassador_slug])
    if individual.present?
      redirect_to "#{root_path}?utm_medium=ambassador&ambassador=#{individual.to_param}"
    else
      redirect_to not_found_path
    end
  end

  def connection
  end

  def coming_soon
  end

  def thank_you
  end

  def co2_counter
    @funded_innovations = FundedInnovation.all
    # TODO FundedInnovation.sum("CAST(co2_reduction -> '2022' AS NUMERIC)").to_i here
    @total_co2_2022 = @funded_innovations.pluck(:co2_reduction).map { |co2_values| co2_values.try("2022").to_i }.sum

    # TODO have emissions in db with categories
    @tftp_emissions = 64_000
  end

  private

  def set_home_variables
    # TODO: Remove the ones that are not necessaryy for company home ?
    @funded_innovations = Innovation.with_picture.includes(:funded_innovation).on_home_in_funded_section.decorate
    @recent_shareholders = Individual.with_picture.includes(:shares_purchases)
      .joins(:picture_attachment).to_display.order("created_at DESC").limit(7)
    @star_shareholders = Individual.with_picture.includes(:shares_purchases)
      .where(id: HighlightedContent.first&.associate_ids).sample(2)
    @future_fundings = Innovation.with_picture.on_home_in_future_funding.decorate
    @total_raised = SharesPurchase.total_raised
    @press_category = Category.find_by_title(Category::PRESS_TITLE)
    @total_shareholders = StatisticsCollecter.new.shareholders_count[:all]
    @current_episode = Episode.current.decorate
    @statistics = StatisticsCollecter.new.all_monthly_data
    @annual_accounts_link = custom_content_path(Content.find(Content::ANNUAL_ACCOUNTS_ID))
    @banner = TemporaryBanner.current
  end

  def set_home_choice_cookie(value)
    cookies.signed[:home_choice] = {value: value, expires: 6.months}
  end
end
