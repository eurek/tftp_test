class Innovation < ApplicationRecord
  include CountryConcern
  include PgSearch::Model
  extend Mobility

  pg_search_scope :search_content, against:
    [
      :name,
      :short_description_i18n,
      :founders,
      :problem_solved_i18n,
      :solution_explained_i18n,
      :potential_clients_i18n,
      :differentiating_elements_i18n
    ],
    using: {
      tsearch: {prefix: true}
    },
    ignoring: :accents

  translates :short_description, :problem_solved, :solution_explained, :potential_clients,
    :differentiating_elements
  paginates_per 18

  belongs_to :action_lever, optional: true
  belongs_to :action_domain, optional: true
  has_many :notifications, as: :subject, dependent: :destroy
  belongs_to :submission_episode, class_name: "Episode", optional: true, foreign_key: "submission_episode_id"
  has_many :evaluations, dependent: :destroy
  has_many :evaluators, source: :individual, through: :evaluations
  has_one :funded_innovation, required: false, dependent: :destroy
  has_one_attached :picture

  accepts_nested_attributes_for :funded_innovation, allow_destroy: true

  validates :status, :external_uid, :name, presence: true
  validates :external_uid, uniqueness: true
  validates :rating, numericality: {greater_than_or_equal_to: 0}
  validates :rating, numericality: {less_than_or_equal_to: 5}
  validate :valid_country_code, unless: -> { country.blank? }

  before_validation :normalize_country
  after_save :notify_new_evaluation, if: :saved_change_to_evaluations_amount?
  after_save :associate_to_submission_episode, if: :saved_change_to_submitted_at?

  enum status: {
    received: "received",
    submitted_to_evaluations: "submitted_to_evaluations",
    submitted_to_scientific_comity: "submitted_to_scientific_comity",
    submitted_to_economical_tests: "submitted_to_economical_tests",
    submitted_to_general_assembly: "submitted_to_general_assembly",
    star: "star"
  }, _suffix: :status

  enum displayed_on_home: {
    in_funded_section: "in_funded_section",
    in_future_funding: "in_future_funding"
  }, _prefix: :on_home

  scope :by_submission_date, -> { order(submitted_at: :desc) }
  scope :submitted_to_evaluations, -> { where(status: statuses.keys.last(5)) }
  scope :submitted_to_scientific_comity, -> { where(status: statuses.keys.last(4)) }
  scope :submitted_to_economical_tests, -> { where(status: statuses.keys.last(3)) }
  scope :submitted_to_general_assembly, -> { where(status: statuses.keys.last(2)) }
  scope :star, -> { where(status: [:star]) }
  scope :with_picture, -> { includes(picture_attachment: :blob) }

  def to_param
    [id, name.parameterize].join("-")
  end

  def is_being_evaluated?
    selection_period.present? && selection_period == Episode.current.decorate.display_code
  end

  private

  def notify_new_evaluation
    changes = saved_changes[:evaluations_amount]
    if changes[1].present? && changes[1] > changes[0].to_i
      Notification.create(subject: self)
    end
  end

  def associate_to_submission_episode
    submission_episode = Episode.where("started_at <= ?", submitted_at).where("finished_at >= ?", submitted_at).first
    update(submission_episode: submission_episode)
  end
end
