namespace :users do
  desc "Detect language of reasons to join"
  task detect_language: :environment do
    Rails.logger.level = 0

    counter = 0
    while counter < 10000
      puts "Detecting language for next 100"
      reasons = User.where.not(reasons_to_join: nil)
        .where.not(reasons_to_join: "")
        .where(locale: [])
        .limit(100)
        .pluck(:id, :reasons_to_join)

      detections = DetectLanguage.detect(reasons.map { |reason| reason[1] })

      reasons.each_with_index do |reason, index|
        possibilities = detections[index]
        User.find(reason[0]).update_column(:locale, possibilities.map { |possibility| possibility["language"] })
      end

      counter += 100
    end
  end
end
