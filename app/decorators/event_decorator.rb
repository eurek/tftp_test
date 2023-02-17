class EventDecorator < ApplicationDecorator
  delegate_all

  def date_display
    if object.date.to_s(:time) == "00:00"
      I18n.l(object.date.to_date, format: :long)
    else
      "#{I18n.l(object.date, format: :long).upcase_first} #{object.timezone}"
    end
  end
end
