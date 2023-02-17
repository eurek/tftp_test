class Content < ApplicationRecord
  include ContentSearch
  extend Mobility
  include PgSearch::Model
  include CmsModel
  require "nokogiri"

  translates :title, :body, :meta_title, :meta_description, :cover_image_alt, :short_title, :status
  multisearchable against: [
    :title_i18n,
    :slug,
    :meta_title_i18n,
    :meta_description_i18n,
    :body_i18n,
    :short_title_i18n
  ]
  paginates_per 60

  AUTHORIZED_STATUSES = [
    "draft", "ready for reread", "reread for translation", "reread for spelling", "published"
  ].freeze
  CONTENT_CHARTER_ID = 23
  QUICK_ACTIONS = 591
  EVALUATOR_CONTENT_ID = 214
  ANNUAL_ACCOUNTS_ID = 391
  INVESTMENT_BRIEF_ID = 44
  PRESS_KIT_ID = 210
  OPEN_SOURCE_FILE_ID = 556
  GREENWASHING_FILE_ID = 338

  has_many_attached :body_attachments
  has_one_attached :cover_image
  scope :with_cover, -> { includes(cover_image_attachment: :blob) }

  has_many :content_tags, dependent: :destroy
  has_many :tags, through: :content_tags
  belongs_to :category
  belongs_to :call_to_action, optional: true

  before_save :set_target_blank_in_body_links, :set_html_elements_width

  validates :status_i18n, json_inclusion: {
    in: AUTHORIZED_STATUSES,
    default: "draft",
    attribute_name: :status
  }

  scope :ordered_and_published, lambda {
    contents = where("status_i18n -> ? = ?", I18n.locale, "published".to_json)
    contents = contents.or(where("status_i18n -> ? = ?", :en, "published".to_json)) unless I18n.locale == :fr
    contents.includes(:category).order(weight: :desc, updated_at: :desc)
  }

  def related_contents
    @related_contents ||= if tags.empty?
      Content.where(category_id: category_id)
    else
      Content.left_outer_joins(:tags).where("tags.id": tags.pluck(:id))
    end.ordered_and_published.where.not(id: id).distinct.last(3)
  end

  def set_target_blank_in_body_links
    return if body_i18n[I18n.locale].blank?

    content_body = Nokogiri::HTML.parse(body_i18n[I18n.locale])
    content_body.css("a").each do |link|
      link["target"] = "_blank"
    end
    self.body = content_body.at("body").inner_html
  end

  def set_html_elements_width
    return if body_i18n[I18n.locale].blank?

    content_body = Nokogiri::HTML.parse(body_i18n[I18n.locale])
    content_body.css("[width]").each do |element|
      element["width"] = "100%"
    end
    self.body = content_body.at("body").inner_html
  end

  def allow_locale?(locale = I18n.locale)
    category.allow_locale?(locale) && status(locale: locale) == "published"
  end

  def self.highlighted_time_media
    ordered_and_published
      .joins(:category)
      .joins(:cover_image_attachment)
      .where(categories: {title: Category::MEDIA_TITLE})
      .last
  end
end
