module UserHelper
  def sign_in_hint(pending_param)
    t("private_space.sign_in.hint") if pending_param == "true"
    # this param will be present in the sign in link sent by email to the share holders
  end

  def login_link
    if current_user.present?
      user_dashboard_path(locale: I18n.locale)
    else
      new_user_session_path(locale: I18n.locale)
    end
  end
end
