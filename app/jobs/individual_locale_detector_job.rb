class IndividualLocaleDetectorJob < ActiveJob::Base
  queue_as :default

  def perform(individual_id)
    @individual = Individual.find(individual_id)

    begin
      possibilities = DetectLanguage.detect(@individual.reasons_to_join)
    rescue DetectLanguage::Error
      return IndividualLocaleDetectorJob.set(wait: 1.day).perform_later(@individual.id)
    end

    @individual.update(
      locale: possibilities
        .filter { |possibility| possibility["isReliable"] }
        .map { |possibility| possibility["language"] }
    )
  end
end
