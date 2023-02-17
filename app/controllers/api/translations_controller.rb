class Api::TranslationsController < Api::ApiController
  skip_before_action :authenticate_api!

  def get
    render json: I18n.t(params.dig(:translation_key), locale: params.dig(:locale)).to_json, status: :ok
  end
end
