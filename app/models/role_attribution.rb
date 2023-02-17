class RoleAttribution < ApplicationRecord
  belongs_to :role
  belongs_to :entity, polymorphic: true

  validates :entity_type, inclusion: {in: ["Company", "Individual"]}
end
