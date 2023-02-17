class NotificationDecorator < ApplicationDecorator
  include Rails.application.routes.url_helpers
  delegate_all

  def icon
    if object.subject_type == "Event"
      "icones/events.svg"
    elsif object.subject_type == "Innovation"
      "icones/received_innovations.svg"
    else
      "icones/shareholders.svg"
    end
  end

  def name
    if object.subject_type == "Event"
      object.subject.title
    elsif object.subject_type == "Innovation"
      object.subject.name
    elsif object.subject_type == "Individual"
      object.subject.full_name
    else
      raise "Unknown class"
    end
  end

  def link
    if object.subject_type == "Event"
      events_path
    elsif object.subject_type == "Innovation"
      innovations_path
    elsif object.subject_type == "Individual"
      shareholders_path
    else
      raise "Unknown class"
    end
  end
end
