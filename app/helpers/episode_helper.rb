module EpisodeHelper
  def fundraising_percentage(fundraising_goal, total_raised)
    if total_raised / fundraising_goal.to_f * 100 < 0.5
      0.5
    else
      total_raised / fundraising_goal.to_f * 100
    end
  end
end
