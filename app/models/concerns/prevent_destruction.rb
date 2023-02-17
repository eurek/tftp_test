module PreventDestruction
  extend ActiveSupport::Concern

  included do
    before_destroy :prevent_destruction

    private

    def prevent_destruction
      message = I18n.t("errors.messages.cannot_be_deleted", model: self.class.model_name.human)
      errors.add(:base, message)
      throw :abort, message
    end
  end
end
