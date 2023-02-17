class RoadmapTask < ApplicationRecord
  extend Mobility
  translates :title, :text

  validates :title_i18n, json_presence: {attribute_name: :title}
  validates :duration_type, presence: true
  validates :category, presence: true

  # This part is dedicated to the bi-directional looped associations
  # Followed this SO thread : https://stackoverflow.com/questions/25493368/many-to-many-self-join-in-rails/25493403#25493403
  # necessary as 'children roadmap task'
  has_many :prerequisites, foreign_key: :dependent_id, class_name: "Prerequisite", dependent: :destroy
  has_many :prerequisite_tasks, through: :prerequisites, source: :necessary
  # dependent as 'parent roadmap task'
  has_many :dependent_prerequisites, foreign_key: :necessary_id, class_name: "Prerequisite", dependent: :destroy
  has_many :dependent_tasks, through: :dependent_prerequisites, source: :dependent

  enum duration_type: {
    short: "short",
    medium: "medium",
    long: "long"
  }, _suffix: :term

  enum status: {
    to_do: "to_do",
    in_progress: "in_progress",
    done: "done"
  }, _prefix: :status

  enum category: {
    community: "community",
    structure: "structure",
    funding: "funding",
    enterprise_creation: "enterprise_creation"
  }, _suffix: :category

  scope :done, -> {
    where.not(done_at: nil).or(where(status: :done)).order(done_at: :asc)
  }

  scope :not_done, -> {
    where(done_at: nil).where.not(status: :done).order(position: :asc)
  }
end
