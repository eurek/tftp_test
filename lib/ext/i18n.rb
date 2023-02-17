require "i18n"

module I18n
  class << self
    alias original_localize localize
    def localize(object, **options)
      object.present? ? original_localize(object, **options) : nil
    end
    alias l localize
  end
end
