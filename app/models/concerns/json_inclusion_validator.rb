class JsonInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    localized_value = value && value.stringify_keys[I18n.locale.to_s]
    return if options[:in].include?(localized_value)

    if localized_value.blank? && options[:default]
      record.public_send(
        "#{attribute}=",
        (value || {}).merge({I18n.locale.to_s => options[:default]})
      )
    else
      record.errors.add(
        options.key?(:attribute_name) ? options[:attribute_name] : attribute,
        "'#{localized_value}' is not an authorized value: #{options[:in].join(", ")}"
      )
    end
  end
end
