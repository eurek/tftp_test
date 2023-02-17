class Api::CurrentSituationsController < Api::ApiController
  def update_total_shareholders
    current_situation = CurrentSituation.first
    current_situation.update!(total_shareholders: params["total_shareholders"])
    render json: current_situation.as_json, status: :ok
  end
end
