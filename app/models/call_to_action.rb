class CallToAction < ApplicationRecord
  extend Mobility
  translates :text, :button_text, :href

  has_many :contents, dependent: :nullify

  def display_name
    text + " " + button_text
  end
end
