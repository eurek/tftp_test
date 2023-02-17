class AbsoluteLinkable < Module
  def initialize(attributes = [])
    super() do
      extend ActiveSupport::Concern
      class_methods do
        define_method :linkable_attributes do
          attributes
        end
      end

      included do
        before_validation :make_links_absolute
        define_method :make_links_absolute do
          self.class.linkable_attributes.each do |attribute|
            if send(attribute).present? && !send(attribute).start_with?("http")
              send("#{attribute}=", "https://#{send(attribute)}")
            end
          end
        end

        private :make_links_absolute
      end
    end
  end
end
