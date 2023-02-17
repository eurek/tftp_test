class IndividualDecorator < ApplicationDecorator
  delegate_all

  def country_name
    return nil if object.country.blank?

    country = ISO3166::Country.find_country_by_alpha3(object.country)
    return nil if country.nil?

    country.translations[I18n.locale.to_s] || country.name
  end

  def do_not_add_company
    if object.shares_purchases&.last&.company_info.present?
      h.t("private_space.choose_company.do_not_add_company.company_share_holder")
    else
      h.t("private_space.choose_company.do_not_add_company.individual_share_holder")
    end
  end

  def greetings
    if object.first_name.present?
      "#{h.raw(h.t("private_space.dashboard.hello"))}, #{object.first_name}."
    else
      "#{h.raw(h.t("private_space.dashboard.hello"))}."
    end
  end

  def current_job_short
    object.current_job&.slice(0, 45)
  end

  def refund_link
    if object.shareholder?
      build_refund_link("https://automate-me.typeform.com/to/W5zA0RvK")
    end
  end

  def recurring_purchase_link
    if I18n.locale == :fr && object.shareholder?
      build_refund_link("https://automate-me.typeform.com/to/H3NWD1Jq")
    end
  end

  def completion_rate
    rate = 0.3
    rate += 0.1 if object.country.present?
    rate += 0.1 if object.city.present?
    rate += 0.1 if object.date_of_birth.present?
    rate += 0.1 if object.description.present?
    rate += 0.1 if object.reasons_to_join.present?
    rate += 0.1 if object.current_job.present?
    rate += 0.2 if object.picture.attached?
    rate.round(2)
  end

  private

  def build_refund_link(base_url)
    return unless address.present? && zip_code.present? && city.present? && date_of_birth.present?

    params = {
      mail: email,
      prenom: first_name,
      nom: last_name,
      adresserue: address,
      cp: zip_code,
      ville: city,
      datenaissance: I18n.l(date_of_birth, locale: :fr)
    }
    "#{base_url}?#{params.to_query}"
  end
end
