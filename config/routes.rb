Rails.application.routes.draw do

  # For details on theDSL available within this file, see http://guides.rubyonrails.org/routing.html

  namespace :forest do
    post "/actions/mark-as-paid", to: "shares_purchases#mark_as_paid"
    post "/actions/request-subscription-bulletin", to: "shares_purchases#request_subscription_bulletin"
    post "/actions/generate-subscription-bulletin-recurring",
      to: "shares_purchases#generate_subscription_bulletin_recurring"
    post "actions/send-confirmation-email", to: "shares_purchases#send_confirmation_email"
    post "/actions/mark-as-duplicated", to: "shares_purchases#mark_as_duplicated"
    post "/actions/mark-as-not-duplicated", to: "shares_purchases#mark_as_not_duplicated"
    post "actions/send-account-creation-email", to: "individuals#send_account_creation_email"
  end

  mount ForestLiana::Engine => "/forest"

  scope "(:locale)", locale: /[a-z]{2}/ do
    devise_for :admin_users, ActiveAdmin::Devise.config
    devise_for :users, skip: [:registrations], controllers: {confirmations: "confirmations"}
    ActiveAdmin.routes(self)

    root "pages#home"
    get "for-companies", to: "pages#company_home", as: "company_home"

    get "vision", to: "pages#vision"
    get "connection", to: "pages#connection"
    get "devenir-associee", to: redirect { |path_params, _req| "/#{path_params[:locale]}/buy-shares-choice" }
    get "thank-you", to: "pages#thank_you"
    get "co2-counter", to: "pages#co2_counter", as: "co2_counter"

    get "pages/:slug", to: "pages#show", as: "page"

    get "/404", to: "errors#not_found", as: :not_found
    get "/422", to: "errors#unacceptable"
    get "/500", to: "errors#internal_error"

    get "/coming-soon", to: "pages#coming_soon", as: :coming_soon

    scope "/shareholders" do
      get "map", to: "shareholders#map", as: "shareholders_map"
      get "user/:slug", to: "shareholders#show_individual", as: "shareholder_individual_show"
      get "company/:slug", to: "shareholders#show_company", as: "shareholder_company_show"
    end

    resources :shareholders, only: %i[index]
    resources :roadmap_tasks, only: %i[index show], path: :roadmap
    resources :problems, only: %i[index show]
    resources :badges, only: %i[show]
    resources :shares_purchases, only: %i[index]

    scope "/shares_purchases" do
      get "remove_company_association",
        to: "shares_purchases#remove_company_association",
        as: "remove_shares_purchase_to_company_association"
    end

    scope "/users" do
      devise_scope :user do
        get "/profile", to: "users#edit_profile", as: "user_profile"
        patch "/update", to: "users#update", as: "update_user"
        put "/confirmation", to: "confirmations#update", as: :update_user_confirmation
        get "/edit", to: "registrations#edit", as: "edit_user_registration"
        put "/", to: "registrations#update", as: "user_registration"
        delete "/", to: "registrations#destroy", as: "destroy_registration"
        get "/dashboard", to: "users#dashboard", as: "user_dashboard"
        get "/finish-onboarding", to: "users#finish_onboarding", as: "finish_onboarding"
        get "/badges", to: "users#badges", as: "user_badges"
        delete "/picture", to: "users#delete_profile_picture", as: "delete_user_picture"
        get "remove-employer", to: "users#remove_employer", as: "remove_employer"
        get "/assign_employer", to: "users#assign_employer", as: "assign_employer"
      end
    end

    resources :companies, only: %i[new create index]
    scope "/companies" do
      get "/choose", to: "companies#choose", as: "choose_company"
      get "/select_as_shareholder", to: "companies#select_as_shareholder", as: "select_company_as_shareholder"
      get "/edit/:id", to: "companies#edit", as: "edit_company"
      patch "/update/:id", to: "companies#update", as: "update_company"
      delete "/:id/logo", to: "companies#delete_logo", as: "company_delete_logo"
    end

    scope "/galaxy" do
      get "/", to: "galaxy#home", as: "galaxy"
      get "/planets", to: "galaxy#planets"
      get "/stars", to: "galaxy#stars"
      get "/comets", to: "galaxy#comets"
      get "/quarks", to: "galaxy#quarks"
      get "/planet-leaders", to: "galaxy#planet_leaders"
      get "/comet-leaders", to: "galaxy#comet_leaders"
      get "/gluons", to: "galaxy#gluons"
      get "/ambassadors", to: "galaxy#ambassadors"
      get "/keepers", to: "galaxy#keepers"
    end

    resources :innovations, only: %i[index show]
    get "/submit-innovation", to: "innovations#submit", as: "submit_innovation"

    resources :events, only: %i[index show]
    get "/live", to: "notifications#index", as: "live"

    resources :episodes, only: :show

    namespace :api, defaults: {format: "json"} do
      resources :badges, only: :create
      resources :roles, only: :create
      resources :events, only: :create
      resources :innovations, only: :create
      resources :funded_innovations, only: :create
      resources :episodes, only: :create
      resources :individuals, only: :create
      resources :shares_purchases, only: :create
      get "shares_purchases/:typeform_answer_uid", to: "shares_purchases#show", as: "shares_purchase"
      post "shares_purchases/sign", to: "shares_purchases#zoho_sign", as: "sign_shares_purchase"
      post "shares_purchases/subscription-bulletin", to: "shares_purchases#attach_subscription_bulletin",
        as: "attach_subscription_bulletin"
      post "individuals/badges", to: "users#update_badges", as: "update_individual_badges"
      post "individuals/roles", to: "users#update_roles", as: "update_individual_roles"
      get "users/:external_uid", to: "users#show", as: "user"
      post "users/missing", to: "users#missing", as: "missing_users"
      post "companies/:id/badges", to: "companies#update_badges", as: "update_company_badges"
      post "companies/:id/roles", to: "companies#update_roles", as: "update_company_roles"
      post "statistics/update", to: "statistics#update", as: "update_statistics"
      post "current_situations/update_total_shareholders",
        to: "current_situations#update_total_shareholders",
        as: "update_total_shareholders"
      get "translations", to: "translations#get", as: "translations"
    end

    I18n.available_locales.without(:en).each do |locale|
      scope "/#{I18n.t("routes.about", locale: locale)}" do
        get ":category/:slug", to: "contents#redirect_to_show"
        get ":category", to: "contents#redirect_to_index"
      end

      scope "/#{I18n.t("routes.sponsorship-campaign", locale: locale)}" do
        get "/#{I18n.t("routes.dashboard", locale: locale)}", to: redirect("/#{locale}/sponsorship-campaign/dashboard")
        get "/:id", to: redirect { |path_params| "/#{locale}/sponsorship-campaign/#{path_params[:id]}" }
      end

      %w[become-shareholder become-shareholder-company buy-shares-choice offer-shares
         offer-shares-company].each do |path|
        get I18n.t("routes.#{path}", locale: locale), to: redirect("/#{locale}/#{path}")
      end
    end

    get "/tout-savoir/agir/aider-proposer/les-teams-for-the-planet", to: redirect("/fr/galaxy")

    scope "/about" do
      get "act/help-suggest/les-teams-for-the-planet-en", to: redirect("/en/galaxy")

      get ":category/:slug", to: "contents#show", as: "content"
      get ":category", to: "contents#index", as: "contents"
    end

    scope "/sponsorship-campaign" do
      get "/dashboard", to: "sponsorship_campaigns#dashboard", as: "sponsorship_campaign_dashboard"
      get "/:id", to: "sponsorship_campaigns#public_show", as: "sponsorship_campaign_public_show"
    end

    get "become-shareholder", to: "shares_purchases#become_shareholder"
    get "become-shareholder-company", to: "shares_purchases#become_shareholder_company"
    # TODO: Put back buy-shares-choice former route after end of operation
    get "buy-shares-choice",
      to: redirect(ENV["TYPEFORM_OPERATION_URL"] || "https://weljdegg9x4.typeform.com/to/snOEImbk"),
      as: :temporary_buy_shares_choice
    get "shares-purchase-choice", to: "shares_purchases#buy_shares_choice", as: :buy_shares_choice
    get "offer-shares", to: "shares_purchases#offer_shares"
    get "offer-shares-company", to: "shares_purchases#offer_shares_company"
    get "use-gift-coupon", to: "shares_purchases#use_gift_coupon"
  end

  post "/image-upload", to: "image_uploads#create"
  delete "/image-upload", to: "image_uploads#destroy"

  require "sidekiq/web"
  authenticate :admin_user do
    mount Sidekiq::Web => "/sidekiq"
    mount PgHero::Engine, at: "pghero"
  end

  get "/:ambassador_slug", to: "pages#ambassador_landing",
    constraints: {ambassador_slug: /[0-z\.]+/},
    as: :ambassador_landing
end
