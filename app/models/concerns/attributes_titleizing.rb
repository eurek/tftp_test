class AttributesTitleizing < Module
  def initialize(keys = [])
    super() do
      extend ActiveSupport::Concern
      class_methods do
        define_method :titleized_keys do
          keys
        end
      end

      included do
        before_validation :titleize_fields
        define_method :titleize_fields do
          self.class.titleized_keys.each do |key|
            send((key.to_s + "=").to_sym, send(key)&.split("-")&.map(&:titleize)&.join("-"))
          end
        end

        private :titleize_fields
      end
    end
  end
end
