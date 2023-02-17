class EventNotifierJob < ActiveJob::Base
  queue_as :default

  def perform(minutes_to_now = 15)
    started_events = Event.select_objects_between(:date, Time.now - minutes_to_now.minutes, Time.now)

    started_events.each do |event|
      unless Notification.find_by(subject: event).present?
        Notification.create(subject: event, created_at: event.date)
      end
    end
  end
end
