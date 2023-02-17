class Accomplishment < ApplicationRecord
  belongs_to :entity, polymorphic: true
  belongs_to :badge

  validates :entity_type, inclusion: {in: ["Company", "Individual"]}
end
