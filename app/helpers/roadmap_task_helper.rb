module RoadmapTaskHelper
  def task_color(task)
    case task.category
    when "community"
      "lagoon"
    when "structure"
      "purple"
    when "funding"
      "red"
    when "enterprise_creation"
      "green"
    else
      ""
    end
  end

  def status_display(task)
    if task.status_done? && task.done_at.present?
      "#{I18n.t("activerecord.attributes.roadmap_task.done_at")} #{l task.done_at&.to_date, locale: params[:locale]}"
    else
      human_enum_name(task, :status)
    end
  end
end
