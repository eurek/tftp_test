module EventHelper
  def event_categories
    Event.categories.to_a.map do |category|
      [I18n.t("activerecord.attributes.event.categories.#{category[0]}"), category[1]]
    end
  end

  def event_locales
    Event.reorder("").distinct.pluck(:locale).map do |locale|
      [I18n.t("common.language", locale: locale), locale]
    end
  end

  def event_cover_image(event, size)
    if event.picture.attached? && event.picture.variable?
      url_for(event.picture.variant(resize_to_limit: size))
    elsif event.picture.attached?
      url_for(event.picture)
    else
      image_url "icones/events.svg"
    end
  end
end
