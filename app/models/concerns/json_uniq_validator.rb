class JsonUniqValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    value.keys.each do |key|

      if record.class.where.not(id: record.id).find_by("#{attribute} -> ? = ?", key, value[key].to_json)
        record.errors.add(
          options.key?(:attribute_name) ? options[:attribute_name] : attribute,
          "variant #{key} is not unique"
        )
      end
    end
  end
end
