class Statistic < ApplicationRecord
  validates :date, presence: true, uniqueness: true

  default_scope { order(date: :asc) }
end
