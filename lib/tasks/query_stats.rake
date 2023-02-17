namespace :query_stats do
  desc "Capture statistics on db queries and save them"
  task capture: :environment do
    QueryStatsCapturerJob.perform_later
    QueryStatsCapturerJob.set(wait: 5.minutes).perform_later
  end
end
