class Event < ApplicationRecord
  include StatisticsConcern

  has_one_attached :picture
  scope :with_picture, -> { includes(picture_attachment: :blob) }

  has_many :notifications, as: :subject, dependent: :destroy

  validates :title, :date, :locale, :registration_link, presence: true
  validates :external_uid, presence: true, uniqueness: true

  before_save :downcase_locale

  enum category: {
    conference: "conference",
    workshop: "workshop",
    videoconference: "videoconference",
    course: "course"
  }

  default_scope { order(date: :asc) }

  scope :incoming, -> {
    where(
      "date >= :midnight_today AND date < :three_weeks_later",
      midnight_today: Date.today.midnight,
      three_weeks_later: Time.now + 3.weeks
    )
  }

  scope :passed, -> {
    where(
      "date < :midnight_today AND date > :three_weeks_before",
      midnight_today: Date.today.midnight,
      three_weeks_before: Time.now - 3.weeks
    )
  }

  private

  def downcase_locale
    self.locale = locale.downcase
  end
end
