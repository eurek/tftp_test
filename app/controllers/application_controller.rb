class ApplicationController < ActionController::Base
  include ContentHelper
  http_basic_authenticate_with name: ENV["STAGING_LOGIN"], password: ENV["STAGING_PASSWORD"] if Rails.env.staging?

  around_action :switch_locale
  before_action :set_navbar_menu_links, :set_footer_links, :set_external_links, :authenticate_user!, unless: :admin?
  before_action :set_admin_locale, if: :admin?

  def admin?
    request.controller_class.module_parents.include?(Admin)
  end

  def switch_locale
    # If there is a language in URL and it's available in the app
    if ::I18n.available_locales.include?(params[:locale]&.to_sym)
      # Set locale to the provided one
      ::I18n.locale = params[:locale]&.to_sym if ::I18n.locale != params[:locale]&.to_sym

      # Show content
      return yield
    end

    # Select language preferences from browser
    languages = browser.accept_language.map(&:code)

    # Select the first language available, fallback to english
    locale = languages.find { |l| ::I18n.available_locales.include?(l.to_sym) } || :en

    # Redirect to the target page with locale
    redirect_to url_for(
      application_params.merge(locale: locale.to_s, only_path: true)
    )
  end

  # Prevents to require adding the locale to every URL helpers
  def default_url_options
    {locale: ::I18n.locale}
  end

  protected

  def current_user
    @current_user ||= super.tap do |user|
      ::ActiveRecord::Associations::Preloader.new.preload(user, :individual)
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a? AdminUser
      admin_root_path
    elsif resource.pending
      user_profile_path
    else
      user_dashboard_path
    end
  end

  private

  def set_user
    @user = current_user
  end

  def application_params
    params.permit(:locale, :category, :slug, :utm_source, :utm_medium, :utm_campaign, :utm_sponsor,
      :reset_password_token, :model, :id, :attribute, :confirmation_token, file: [], tag: [])
  end

  def set_admin_locale
    I18n.locale = params[:locale]
  end

  def set_footer_links
    @legal = Page.find_by(slug: "mentions-legales")
    @confidentiality = Page.find_by(slug: "protection-donnees-personnelles")
    @cookies = Page.find_by(slug: "cookies")
  end

  def set_navbar_menu_links
    @navbar_menu_links = Rails.cache.fetch("#{params[:locale]}_navbar_menu_links", expires_in: 10.minutes) do
      {
        press_clips: contents_path_without_fallback(Category.find_by_title(Category::PRESS_TITLE)),
        faq: contents_path_with_fallback(Category.find_by_title(Category::FAQ_TITLE)),
        strategy_and_governance: contents_path_with_fallback(
          Category.find_by_title(Category::STRATEGY_AND_GOVERNANCE_TITLE)
        ),
        climate_change: contents_path_with_fallback(Category.find_by_title(Category::CLIMATE_CHANGE_TITLE)),
        files: contents_path_with_fallback(Category.find_by_title(Category::FILES_TITLE)),
        legal_documents: contents_path_with_fallback(Category.find_by_title(Category::LEGAL_DOCUMENTS_TITLE)),
        communication_documents: contents_path_with_fallback(
          Category.find_by_title(Category::COMMUNICATION_DOCUMENTS_TITLE)
        ),
        events: events_path,
        evaluators: custom_content_path(Content.find(Content::EVALUATOR_CONTENT_ID)),
        galaxy: galaxy_path,
        submit_innovation: submit_innovation_path,
        received_innovations: innovations_path(status: "submitted_to_evaluations"),
        stars: innovations_path(status: "star"),
        quick_actions: custom_content_path(Content.find(Content::QUICK_ACTIONS)),
        vision: vision_path,
        shareholders: shareholders_path,
        roadmap_tasks: roadmap_tasks_path,
        problems: problems_path,
        become_shareholder: become_shareholder_path,
        become_shareholder_company: become_shareholder_company_path,
        time_media: contents_path_without_fallback(
          Category.find_by_title(Category::MEDIA_TITLE)
        ),
        notifications: live_path,
        jobs: "https://jobs-time.softr.app/",
        co2_counter: co2_counter_path
      }
    end
  end

  def set_external_links
    @external_links = ExternalLinkManager.first
  end
end
