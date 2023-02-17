class Forest::IndividualsController < ForestLiana::SmartActionsController
  # TODO: Test this in request specs
  def send_account_creation_email
    individual = set_individual

    if individual.user&.confirmed?
      return render status: 400, json: {error: "This individual has already created his/her account"}
    end

    CommunicationLocaleSetter.new(individual).set
    if individual.user.present?
      individual.user.resend_confirmation_instructions
      render json: {success: "The account creation email has been sent again"}
    else
      User.create(individual: individual)
      render json: {success: "The account has been created and the mail has been sent"}
    end
  end

  private

  def set_individual
    individual_id = ForestLiana::ResourcesGetter.get_ids_from_request(params, forest_user).first
    Individual.find(individual_id)
  end
end
