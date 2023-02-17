class BadgeCategorizer
  def initialize(badges)
    @badges = badges
  end

  # picture mode can be 'light' or 'dark'
  def categorize(picture_mode)
    subquery = Accomplishment.group(:badge_id).select("COUNT(*) AS count_all, badge_id")
    query = @badges.includes("picture_#{picture_mode}_attachment": :blob)
      .distinct
      .with(x: subquery).joins("JOIN x ON x.badge_id = badges.id")
      .select("badges.*, x.count_all as accomplishments_count")
    query.group_by(&:category)
  end
end
