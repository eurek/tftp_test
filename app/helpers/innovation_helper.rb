module InnovationHelper
  include ApplicationHelper
  def innovation_tag_and_color(innovation)
    if innovation.status == "received"
      {tag: nil, color: "grey"}
    elsif innovation.status == "star"
      {tag: human_enum_name(innovation, :status), color: "rainforest600"}
    elsif innovation.status == "submitted_to_evaluations" && innovation.is_being_evaluated?
      {tag: I18n.t("innovations.tags.being_evaluated"), color: "lagoon500"}
    elsif innovation.status == "submitted_to_evaluations"
      {tag: I18n.t("innovations.tags.evaluated"), color: "lagoon100"}
    else
      {tag: I18n.t("innovations.tags.selected"), color: "rainforest400"}
    end
  end

  # TODO : Hack to disable "submitted" status filter in a quick and dirty way but innovation index design needs to be
  # rethought and this hack removed
  def innovations_path(params = {})
    params[:status] = :submitted_to_evaluations if params[:status].blank?
    super(params)
  end

  def should_display_rating?(innovation)
    if innovation.status == "received"
      false
    elsif innovation.status == "submitted_to_evaluations"
      innovation.rating.present? && innovation.rating >= 0.25 && !innovation.is_being_evaluated?
    else
      innovation.rating.present?
    end
  end

  def innovation_status_link(status)
    if status == "received"
      submit_innovation_path
    elsif status == "submitted_to_evaluations"
      problems_path
    elsif status == "submitted_to_scientific_comity"
      shareholders_path(filters: {roles: [24]})
    elsif status == "star"
      custom_content_path(Content.find(Content::INVESTMENT_BRIEF_ID))
    end
  end

  def remove_filter(current_params, filter_type, applied_filter_id)
    new_params = current_params.deep_dup
    new_params[:filters][filter_type] = new_params[:filters][filter_type] - [applied_filter_id.to_s]
    new_params
  end

  def change_status(current_params, status)
    new_params = current_params.deep_dup
    new_params[:status] = status
    new_params
  end

  def filter_display_name(filter_value, filter_key)
    if filter_key == "episodes"
      filter_value.decorate.display_code
    else
      filter_value.name
    end
  end

  def key_figure_display(attribute)
    return unless attribute.present?

    if attribute.is_a?(Integer)
      number_to_currency(attribute, locale: params[:locale], precision: 0, unit: "€")
    elsif attribute.is_a?(Date)
      l(attribute, format: :long)
    end
  end
end
