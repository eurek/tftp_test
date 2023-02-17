class Api::FundedInnovationsController < Api::ApiController
  def create
    innovation = Innovation.find_by(external_uid: funded_innovation_params[:external_uid])
    return head :not_found if innovation.nil?

    innovation.build_funded_innovation if innovation.funded_innovation.nil?
    innovation.funded_innovation.update!(funded_innovation_params.except(:external_uid, :pictures))
    innovation.funded_innovation.pictures.purge
    funded_innovation_params[:pictures].each do |picture_url|
      innovation.funded_innovation.pictures.attach_from_url(picture_url)
    end

    render json: innovation.funded_innovation.as_json, status: :ok
  end

  private

  def funded_innovation_params
    funded_innov_params = params.require(:innovation).permit(
      :external_uid, :funded_at, :company_created_at, :amount_invested, :video_link, :pitch_deck_link,
      :summary, :scientific_committee_opinion, :carbon_potential, pictures: []
    )
    funded_innov_params[:team_members] = Individual.where(email: params[:innovation][:team_members])
    funded_innov_params
  end
end
