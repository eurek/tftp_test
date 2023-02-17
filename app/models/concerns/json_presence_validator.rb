class JsonPresenceValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.blank? || value.stringify_keys[I18n.locale.to_s].blank?
      key = options.key?(:attribute_name) ? options[:attribute_name] : attribute
      record.errors.add(key, :blank)
    end
  end
end
