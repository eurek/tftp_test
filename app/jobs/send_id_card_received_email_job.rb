class SendIdCardReceivedEmailJob < ActiveJob::Base
  queue_as :default

  def perform(individual_id)
    individual = Individual.find(individual_id)
    return unless individual.id_card_received?

    IndividualMailer.id_card_received_email(individual).deliver_now
  end
end
