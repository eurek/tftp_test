module DatabaseContentModifier
  extend ActiveSupport::Concern

  included do
    ALLOWED_COLUMN_TYPES = [:string, :text, :jsonb].freeze
    IGNORED_COLUMN_SUFFIXES = ["_data"].freeze

    def self.modifiable_columns
      return @modifiable_columns if @modifiable_columns

      columns = self.columns
        .filter { |c| ALLOWED_COLUMN_TYPES.include?(c.type) }
        .reject(&:array?)
        .map(&:name)

      IGNORED_COLUMN_SUFFIXES.each do |suffix|
        columns = columns.reject { |c| c.end_with?(suffix) }
      end

      defined_enums.keys.each do |enum_name|
        columns = columns.reject { |c| c == enum_name.to_s }
      end

      @modifiable_columns ||= columns.map(&:to_sym)
    end

    def self.rewrite_value(value, lambda)
      case value
      when Hash
        value.map do |key, value|
          [key, rewrite_value(value, lambda)]
        end.to_h

      when String
        lambda.call(value)

      when Array
        value.map do |value|
          rewrite_value(value, lambda)
        end

      when Integer
        value

      when TrueClass
        value

      when FalseClass
        value

      when NilClass
        nil

      else
        raise ArgumentError, "Unhandled data type in rewrite_value_for_environment: #{value.class.name}"
      end
    end

    def match_url_to_environment(current_domain, other_domains)
      self.class.modifiable_columns.each do |column|
        value = send(column)
        next if value.nil?

        lambda = lambda do |string_value|
          other_domains.each do |other_domain|
            string_value = string_value.gsub(other_domain, current_domain)
          end
          string_value
        end
        value = self.class.rewrite_value(value, lambda)
        assign_attributes(column => value)
      end
    end

    def replace_content(content, new_content)
      self.class.modifiable_columns.each do |column|
        value = send(column)
        next if value.nil?

        lambda = lambda do |string_value|
          string_value.gsub(content, new_content)
        end
        value = self.class.rewrite_value(value, lambda)
        assign_attributes(column => value)
      end
    end
  end
end
