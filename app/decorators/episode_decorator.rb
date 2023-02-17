class EpisodeDecorator < ApplicationDecorator
  delegate_all

  def display_code
    "S#{object.season_number.to_s.rjust(2, "0")}E#{object.number.to_s.rjust(2, "0")}"
  end

  def fundraising_goal
    object.fundraising_goal || 1_000_000_000
  end

  def cover_image_with_fallback(size)
    if object.cover_image.attached?
      h.url_for(object.cover_image.variant(resize_to_limit: size))
    else
      "forest-with-sunrise.jpg"
    end
  end

  def duration
    h.raw(h.t("episodes.period",
      started_at: I18n.l(object.started_at, format: :medium),
      finished_at: I18n.l(object.finished_at.to_date, format: :medium)))
  end

  def time_status
    if object.current?
      h.raw(h.t("episodes.time_status.current"))
    elsif object.finished_at < Date.today
      h.raw(h.t("episodes.time_status.finished"))
    else
      h.raw(h.t("episodes.time_status.coming"))
    end
  end
end
