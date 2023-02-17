class Badge < ApplicationRecord
  extend Mobility
  translates :description, :fun_description, :name

  has_many :accomplishments, dependent: :destroy
  has_many :individuals, through: :accomplishments, source_type: "Individual", source: :entity
  has_many :companies, through: :accomplishments, source_type: "Company", source: :entity

  has_one_attached :picture_dark
  has_one_attached :picture_light

  validates :name, presence: true
  validates :category, presence: true
  validates :external_uid, uniqueness: true

  enum category: {
    year: "year",
    financial: "financial",
    action: "action",
    event: "event",
    honorific: "honorific",
    special: "special",
    role_actions: "role_actions",
    individual_sponsor: "individual_sponsor",
    help_comet: "help_comet",
    community_planet: "community_planet"
  }, _suffix: :badge

  default_scope { order(position: :asc) }

  BECOME_SHAREHOLDER_BADGE_IDS = [48, 53, 52].freeze
  EVALUATORS_EXTERNAL_UID = "recL2Uzp2d0pgAWjl".freeze
end
