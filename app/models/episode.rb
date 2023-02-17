class Episode < ApplicationRecord
  extend Mobility
  translates :title, :description, :body

  validates :number, :season_number, :started_at, :finished_at, presence: true
  validates_uniqueness_of :number, scope: :season_number
  validate :finished_at_after_started_at

  has_many :submitted_innovations, class_name: "Innovation", dependent: :nullify, foreign_key: "submission_episode_id"
  has_many :funded_innovations, dependent: :nullify, foreign_key: "funding_episode_id"

  scope :ordered_by_season, -> { order(season_number: :asc, number: :asc) }
  scope :past_and_current, -> { where("DATE(started_at) <= ?", Date.today) }

  has_one_attached :cover_image

  after_save :reset_current_episode

  def self.current(with_fallback: true)
    # force in dev env: https://stackoverflow.com/a/7838450/1439489
    Rails.cache.fetch("current_episode", expires_in: 1.day, force: Rails.env.development?) do
      episode = where("started_at <= ?", Date.today).where("finished_at >= ?", Date.today).first

      if !episode && with_fallback
        Sentry.capture_message "No current episode"
        episode = Episode.new(
          number: 0, season_number: 0, started_at: Date.today - 1.month, finished_at: Date.today + 1.month
        )
      end

      episode
    end
  end

  def current?
    self == Episode.current
  end

  def total_raised
    SharesPurchase.where("completed_at <= ?", finished_at).total_raised
  end

  def total_funded_innovations
    FundedInnovation.where("funded_at <= ?", finished_at).count
  end

  private

  def reset_current_episode
    Rails.cache.delete("current_episode")
  end

  def finished_at_after_started_at
    return if finished_at.blank? || started_at.blank?

    if finished_at < started_at
      errors.add(:finished_at, "cannot be before the start date")
    end
  end
end
