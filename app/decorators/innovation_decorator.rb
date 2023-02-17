class InnovationDecorator < ApplicationDecorator
  delegate_all

  def picture_with_fallback(size)
    if object.picture.attached?
      h.url_for(object.picture.variant(resize_to_limit: size))
    else
      h.image_url("innovations-fallback.jpg")
    end
  end

  def evaluations_amount
    if object.evaluations_amount&.nonzero?
      h.raw(h.t("innovations.show.evaluations_amount", count: object.evaluations_amount))
    else
      h.raw(h.t("innovations.show.no_evaluation"))
    end
  end

  def place
    country = ISO3166::Country.find_country_by_alpha3(object.country)
    country_translation = country.translations[I18n.locale.to_s] || country.name unless country.nil?

    if object.city.present? && country.present?
      "#{object.city}, #{country_translation}"
    elsif object.city.present? || country.present?
      object.city || country_translation
    end
  end
end
