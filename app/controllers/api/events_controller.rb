class Api::EventsController < Api::ApiController
  def create
    event = Event.find_or_initialize_by(external_uid: event_params[:external_uid])
    event.update!(event_params.except(:picture))
    event.picture.attach_from_url(event_params[:picture])
    render json: event.as_json, status: :ok
  end

  private

  def event_params
    params.require(:event).permit(
      :external_uid, :title, :description, :locale, :picture, :category, :date, :venue, :registration_link,
      :timezone
    )
  end
end
