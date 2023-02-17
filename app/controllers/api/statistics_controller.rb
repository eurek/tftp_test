class Api::StatisticsController < Api::ApiController
  def update
    statistic = Statistic.find_or_create_by(date: Date.parse(statistic_params[:date]))
    statistic.update!(statistic_params.except(:date))
    render json: statistic.as_json, status: :ok
  end

  private

  def statistic_params
    params.require(:statistics).permit(
      :date, :total_shareholders, :total_innovations_assessed, :total_companies_funded, :total_innovations_assessors
    )
  end
end
