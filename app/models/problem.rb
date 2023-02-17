class Problem < ApplicationRecord
  include PgSearch::Model
  multisearchable against: [:title_i18n, :description_i18n, :action_lever, :domain, :full_content_i18n]

  has_many_attached :full_content_attachments
  has_one_attached :cover_image

  scope :with_cover, -> { includes(cover_image_attachment: :blob) }

  extend Mobility
  translates :title, :description, :full_content

  enum action_lever: {
    zero_emission: "zero_emission",
    energetical_efficacy: "energetical_efficacy",
    sobriety: "sobriety",
    captation: "captation"
  }

  enum domain: {
    energy: "energy",
    industry: "industry",
    transport: "transport",
    agriculture: "agriculture",
    building: "building"
  }

  scope :by_position, -> {
    order(position: :asc)
  }
end
