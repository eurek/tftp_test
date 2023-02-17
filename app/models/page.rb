class Page < ApplicationRecord
  include PageSearch
  include PgSearch::Model
  multisearchable against: [:title_i18n, :body_i18n, :slug]

  extend Mobility
  translates :title, :body

  validates :slug, presence: true, uniqueness: true
end
