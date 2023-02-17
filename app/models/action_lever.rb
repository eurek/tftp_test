class ActionLever < ApplicationRecord
  extend Mobility

  translates :name

  validates :title, presence: true
  validates :name_i18n, json_presence: {attribute_name: :name}

  has_many :innovations, dependent: :nullify

  has_one_attached :icon
end
