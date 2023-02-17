class InnovationsController < ApplicationController
  skip_before_action :authenticate_user!
  layout "static"

  def submit
    @citizens_number = CurrentSituation.first.total_shareholders
  end

  def index
    return redirect_to url_for(params.permit!.merge(status: :submitted_to_evaluations)) if params[:status] == "received"

    @selected_innovations = InnovationsSearch.search(
      status: params[:status],
      term: params[:search] || "",
      levers: params.dig(:filters, :levers),
      domains: params.dig(:filters, :domains),
      episodes: params.dig(:filters, :episodes)
    ).page(params[:page])
    @count = @selected_innovations.total_count
    @filters_params = filters_params(params)
    @applied_filters = @filters_params.deep_dup
    if params.dig(:filters, :levers).present?
      @applied_filters[:filters][:levers] = ActionLever.where(id: @applied_filters[:filters][:levers])
    end
    if params.dig(:filters, :domains).present?
      @applied_filters[:filters][:domains] = ActionDomain.where(
        id: @applied_filters[:filters][:domains]
      )
    end
    if params.dig(:filters, :domains).present?
      @applied_filters[:filters][:episodes] = Episode.where(
        id: @applied_filters[:filters][:episodes]
      )
    end
    @episodes_collection = Episode.includes(:submitted_innovations)
      .where.not(innovations: {submission_episode_id: nil}).ordered_by_season
  end

  def show
    @innovation = Innovation.includes(
      evaluators: [:roles, picture_attachment: :blob, badges: {picture_light_attachment: :blob}],
      funded_innovation: {
        pictures_attachments: :blob,
        team_members: [:roles, picture_attachment: :blob, badges: {picture_light_attachment: :blob}]
      }
    ).find(params[:id]).decorate
    @back_button_link = if params[:applied_filters].present?
      innovations_path(filters_params(params[:applied_filters]))
    else
      innovations_path(status: "submitted_to_evaluations")
    end
    if @innovation.status == "star"
      render "funded_show"
    end
  end

  private

  def filters_params(params)
    params.permit(:search, :status, filters: {levers: [], domains: [], episodes: []})
  end
end
