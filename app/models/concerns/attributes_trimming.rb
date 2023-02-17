class AttributesTrimming < Module
  def initialize(keys = [])
    super() do
      extend ActiveSupport::Concern
      class_methods do
        define_method :trimmed_keys do
          keys
        end
      end
      included do
        before_validation :trim_fields

        define_method :trim_fields do
          # iOS and Android keyboard suggestions for names love to add whitespaces after the suggestion. let's remove it
          # and make sure our data is sanitized
          self.class.trimmed_keys.each do |key|
            send((key.to_s + "=").to_sym, send(key)&.strip)
          end
        end

        private :trim_fields
      end
    end
  end
end
