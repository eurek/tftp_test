class JsonBooleanValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    localized_value = value && value.stringify_keys[I18n.locale.to_s]
    return if [true, false].include?(localized_value)

    if localized_value == "true"
      record.public_send(
        "#{attribute}=",
        (value || {}).merge({I18n.locale.to_s => true})
      )
    else
      record.public_send(
        "#{attribute}=",
        (value || {}).merge({I18n.locale.to_s => false})
      )
    end
  end
end
