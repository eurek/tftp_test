class Api::InnovationsController < Api::ApiController
  def create
    innovation = Innovation.find_or_initialize_by(external_uid: innovation_params[:external_uid])
    action_domain_id = ActionDomain.find_by(title: params[:innovation][:action_domain])&.id
    action_lever_id = ActionLever.find_by(title: params[:innovation][:action_lever])&.id
    innovation.update!(innovation_params
      .except(:picture)
      .merge({action_lever_id: action_lever_id, action_domain_id: action_domain_id}))
    innovation.picture.attach_from_url(innovation_params[:picture])

    render json: innovation.as_json, status: :ok
  end

  private

  def innovation_params
    innov_params = params.require(:innovation).permit(
      :external_uid, :name, :short_description, :problem_solved, :solution_explained, :potential_clients,
      :differentiating_elements, :picture, :status, :submitted_at, :evaluations_amount, :city, :country, :rating,
      :language, :website, :selection_period, founders: []
    )
    innov_params[:evaluators] = Individual.where(email: params[:innovation][:email_evaluators])
    innov_params[:language] = innov_params[:language].downcase
    innov_params
  end
end
