class Category < ApplicationRecord
  include CmsModel

  extend Mobility
  translates :name, :description, :meta_title, :meta_description, :body, :published

  validates :title, uniqueness: true, allow_blank: true
  validates :published_i18n, json_boolean: true

  has_many :tags, dependent: :destroy
  has_many :contents, dependent: :nullify

  ASSOCIATE_CATEGORY_ID = 2
  PRESS_TITLE = "press_clips"
  MEDIA_TITLE = "time_media"
  BLOG_TITLE = "blog"
  FAQ_TITLE = "faq"
  STRATEGY_AND_GOVERNANCE_TITLE = "strategy_and_governance"
  CLIMATE_CHANGE_TITLE = "climate_change"
  FILES_TITLE = "files"
  LEGAL_DOCUMENTS_TITLE = "legal_documents"
  COMMUNICATION_DOCUMENTS_TITLE = "communication_documents"

  def allow_locale?(locale = I18n.locale)
    published(locale: locale) == true
  end
end
