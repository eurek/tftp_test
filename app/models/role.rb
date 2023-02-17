class Role < ApplicationRecord
  extend Mobility
  translates :description, :name

  has_many :role_attributions, dependent: :destroy
  has_many :individuals, through: :role_attributions, source_type: "Individual", source: :entity
  has_many :companies, through: :role_attributions, source_type: "Company", source: :entity

  validates :name, presence: true
  validates :external_uid, uniqueness: true

  ROLE_SHAREHOLDER_EXTERNAL_UID = "recveMmWBjcA0NOgc".freeze
  FOUNDER_ID = 17
  SUPERVISORY_BOARD_ID = 25
  SCIENTIFIC_COMMITEE_ID = 24

  enum attributable_to: {
    user: "user",
    company: "company",
    all: "all"
  }, _prefix: :attributable_to

  default_scope { order(position: :asc) }
  scope :attributable_to_company, -> { where(attributable_to: ["all", "company"]) }
  scope :attributable_to_user, -> { where(attributable_to: ["all", "user"]) }
end
