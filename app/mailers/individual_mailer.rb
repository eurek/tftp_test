class IndividualMailer < ApplicationMailer
  def id_card_received_email(individual)
    @individual = individual
    CommunicationLocaleSetter.new(@individual).set
    mail(
      to: @individual.email,
      subject: I18n.t("individual.id_card_received_email.subject"),
      bcc: "Laurent Morel<laurent@time-planet.com>"
    )
  end
end
