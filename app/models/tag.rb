class Tag < ApplicationRecord
  extend Mobility
  include PgSearch::Model
  include CmsModel
  multisearchable against: [:name_i18n, :slug]

  translates :name, :published

  belongs_to :category
  has_many :content_tags, dependent: :destroy
  has_many :contents, through: :content_tags

  validates :published_i18n, json_boolean: true

  def allow_locale?(locale = I18n.locale)
    category.published(locale: locale) == true
  end
end
