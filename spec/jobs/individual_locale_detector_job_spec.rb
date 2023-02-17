require "rails_helper"

RSpec.describe IndividualLocaleDetectorJob, type: :job do
  describe "#perform" do
    it "saves language detection sent by detect_language api" do
      individual = FactoryBot.create(:individual, reasons_to_join: "I want to buy me a conscience")
      allow(DetectLanguage).to receive(:detect).and_return(
        [{"language" => "en", "isReliable" => true, "confidence" => 6.62}]
      )

      IndividualLocaleDetectorJob.perform_now(individual.id)

      expect(individual.reload.locale).to eq(["en"])
    end

    it "saves possible language detections send by detect_language api when they are all reliable" do
      individual = FactoryBot.create(:individual, reasons_to_join: "Envie d'agir")
      allow(DetectLanguage).to receive(:detect).and_return(
        [
          {"language" => "fr", "isReliable" => true, "confidence" => 6.62},
          {"language" => "it", "isReliable" => true, "confidence" => 6.62},
          {"language" => "pt", "isReliable" => true, "confidence" => 6.62}
        ]
      )

      IndividualLocaleDetectorJob.perform_now(individual.id)

      expect(individual.reload.locale).to eq(["fr", "it", "pt"])
    end

    it "saves reliable language detections send by detect_language" do
      individual = FactoryBot.create(:individual, reasons_to_join: "Pour contribuer")
      allow(DetectLanguage).to receive(:detect).and_return(
        [
          {"language" => "fr", "isReliable" => true, "confidence" => 6.94},
          {"language" => "en", "isReliable" => false, "confidence" => 3.88},
          {"language" => "cs", "isReliable" => false, "confidence" => 3.88}
        ]
      )

      IndividualLocaleDetectorJob.perform_now(individual.id)

      expect(individual.reload.locale).to eq(["fr"])
    end

    it "delays job for the next day if daily api limit is reached" do
      now = Time.now
      allow(Time).to receive(:now).and_return(now)
      individual = FactoryBot.create(:individual, reasons_to_join: "Anything")
      allow(DetectLanguage).to receive(:detect).and_raise(DetectLanguage::Error, "Failure: Net::HTTPPaymentRequired")

      IndividualLocaleDetectorJob.perform_now(individual.id)

      assert_enqueued_with(job: IndividualLocaleDetectorJob, at: now + 1.day, args: [individual.id])
    end
  end
end
