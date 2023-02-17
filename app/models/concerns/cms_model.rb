module CmsModel
  extend ActiveSupport::Concern

  included do
    validates :slug, presence: true, uniqueness: true
    validates_format_of :slug, with: /\A[\da-zA-Z-]+\Z/
  end
end
