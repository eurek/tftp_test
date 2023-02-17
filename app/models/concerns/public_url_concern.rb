module PublicUrlConcern
  extend ActiveSupport::Concern

  class_methods do
    def find_by_slug(slug_with_name)
      public_slug = slug_with_name.split("-").first
      find_by(public_slug: public_slug)
    end
  end

  included do
    validates :public_slug, presence: true, uniqueness: true, format: {with: ShortKey.format_regex}

    before_validation :generate_slug, if: -> { public_slug.nil? }

    private

    def generate_slug
      self.public_slug = ShortKey.generate if public_slug.nil?
    end
  end
end
