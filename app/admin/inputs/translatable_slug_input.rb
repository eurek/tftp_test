require_relative "translatable_input"

class TranslatableSlugInput < Formtastic::Inputs::StringInput
  include TranslatableInput

  def input_html_options
    {
      disabled: !object.new_record? &&
        object.created_at < Time.now - 1.hour &&
        !object.send(method, fallback: false).nil? &&
        !object.send("#{method}_i18n_changed?")
    }.merge(super)
  end
end
