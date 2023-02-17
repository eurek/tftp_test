class CurrentSituation < ApplicationRecord
  extend Mobility
  translates :description, :structure

  validates :total_shareholders, presence: true

  FUNDRAISING_START_DATE = Date.parse("05-12-2019")
  OPERATION_100_K_START_TIME = Date.parse("27-12-2022").midnight
  OPERATION_100_K_END_TIME = Date.parse("01-01-2023").midnight
  OPERATION_100_K_GOAL = 100_000
end
