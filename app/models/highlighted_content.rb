class HighlightedContent < ApplicationRecord
  extend Mobility

  translates :associate_ids, :time_media_content_id, :blog_content_id, :reason_to_join_ids

  before_validation :remove_invalid_associate

  private

  def remove_invalid_associate
    self.associate_ids = associate_ids&.reject(&:blank?)
  end
end
