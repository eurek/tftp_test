namespace :notifications do
  desc "Generate notifications for events"
  task event_generate: :environment do
    EventNotifierJob.perform_later
  end
end
