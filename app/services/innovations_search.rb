class InnovationsSearch
  def self.search(term: "", status: "", levers: [], domains: [], episodes: [])
    result = Innovation.includes(picture_attachment: :blob).all.by_submission_date
    result = result.send(status) if status.present? && Innovation.statuses.key?(status)
    unless levers&.reject(&:blank?).blank?
      result = result.joins(:action_lever).where(action_lever: {id: levers})
    end
    unless domains&.reject(&:blank?).blank?
      result = result.joins(:action_domain).where(action_domain: {id: domains})
    end
    unless episodes&.reject(&:blank?).blank?
      result = result.joins(:submission_episode).where(submission_episode: {id: episodes})
    end
    result = result.search_content(term) unless term.blank?
    result
  end
end
