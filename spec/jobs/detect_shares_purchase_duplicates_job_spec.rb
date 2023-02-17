require "rails_helper"

RSpec.describe DetectSharesPurchaseDuplicatesJob, type: :job do
  describe "#perform" do
    it "marks shares purchases as duplicates if the second form was completed less than 24 hours before" do
      individual = FactoryBot.create(:individual)
      first_share_purchase = FactoryBot.create(
        :shares_purchase, individual: individual, form_completed_at: Time.now - 5.hours
      )
      second_share_purchase = FactoryBot.create(
        :shares_purchase, individual: individual, form_completed_at: Time.now
      )

      DetectSharesPurchaseDuplicatesJob.perform_now(second_share_purchase.id)

      expect(first_share_purchase.reload.is_a_duplicate).to be true
      expect(second_share_purchase.reload.is_a_duplicate).to be true
    end

    it "doesn't mark shares purchases as duplicates if second form was completed more than 24 hours before" do
      individual = FactoryBot.create(:individual)
      first_share_purchase = FactoryBot.create(
        :shares_purchase, individual: individual, form_completed_at: Time.now
      )
      second_share_purchase = FactoryBot.create(
        :shares_purchase, individual: individual, form_completed_at: Time.now - 25.hours
      )

      DetectSharesPurchaseDuplicatesJob.perform_now(second_share_purchase.id)

      expect(first_share_purchase.reload.is_a_duplicate).to be false
      expect(second_share_purchase.reload.is_a_duplicate).to be false
    end

    it "doesn't mark shares purchases as duplicates if second form was completed after first form" do
      individual = FactoryBot.create(:individual)
      first_share_purchase = FactoryBot.create(
        :shares_purchase, individual: individual, form_completed_at: Time.now
      )
      second_share_purchase = FactoryBot.create(
        :shares_purchase, individual: individual, form_completed_at: Time.now + 1.minute
      )

      DetectSharesPurchaseDuplicatesJob.perform_now(first_share_purchase.id)

      expect(first_share_purchase.reload.is_a_duplicate).to be false
      expect(second_share_purchase.reload.is_a_duplicate).to be false
    end

    it "doesn't mark shares purchases as duplicates if they were made by different users" do
      first_share_purchase = FactoryBot.create(:shares_purchase, form_completed_at: Time.now - 5.hours)
      second_share_purchase = FactoryBot.create(:shares_purchase, form_completed_at: Time.now)

      DetectSharesPurchaseDuplicatesJob.perform_now(second_share_purchase.id)

      expect(first_share_purchase.reload.is_a_duplicate).to be false
      expect(second_share_purchase.reload.is_a_duplicate).to be false
    end

    it "doesn't mark shares purchases as duplicates if the first one is canceled" do
      individual = FactoryBot.create(:individual)
      first_share_purchase = FactoryBot.create(
        :shares_purchase, individual: individual, form_completed_at: Time.now - 5.hours, status: :canceled
      )
      second_share_purchase = FactoryBot.create(
        :shares_purchase, individual: individual, form_completed_at: Time.now
      )

      DetectSharesPurchaseDuplicatesJob.perform_now(second_share_purchase.id)

      expect(first_share_purchase.reload.is_a_duplicate).to be false
      expect(second_share_purchase.reload.is_a_duplicate).to be false
    end
  end
end
