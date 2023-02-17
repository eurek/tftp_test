class Api::BadgesController < Api::ApiController
  def create
    badge = Badge.find_or_initialize_by(external_uid: badge_params[:external_uid])
    badge.update!(badge_params.except(:picture_light, :picture_dark))
    badge.picture_light.attach_from_url(badge_params[:picture_light])
    badge.picture_dark.attach_from_url(badge_params[:picture_dark])
    render json: badge.as_json, status: :ok
  end

  private

  def badge_params
    params.require(:badge).permit(
      :external_uid, :name, :description, :fun_description, :picture_light, :picture_dark, :position, :category
    )
  end
end
