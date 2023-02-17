class ActiveAdmin::Views::TableFor
  def column_without_fallback(attribute)
    column attribute do |resource|
      resource.send(attribute, fallback: false)
    end
  end

  def thumbnail_column(attribute)
    column attribute do |resource|
      if resource.send(attribute).attached?
        image_tag(resource.send(attribute).variant(resize_to_limit: [60, 60]), class: "ImagePreview")
      end
    end
  end
end

class ActiveAdmin::Views::AttributesTable
  def row_without_fallback(attribute)
    row attribute do |resource|
      resource.send(attribute, fallback: false)
    end
  end

  def row_image(attribute)
    row attribute do |resource|
      if resource.send(attribute).attached?
        image_tag(resource.send(attribute).variant(resize_to_limit: [200, 200]), class: "ImagePreview")
      end
    end
  end
end

class ActiveAdmin::Views::IndexAsTable::IndexTableFor
  builder_method :index_table_for
end

module ActiveAdminFixResourcesPaths
  extend ActiveSupport::Concern

  # we need at least one method or the module won't exist in rails eyes
  def are_path_fixed
    true
  end

  included do
    # In Admin::Users#show we had an issue causing id_column for resource.shares_purchases to fail because resource_path
    # would return /admin/users/:shares_purchase_id instead of /admin/shares_purchases/:shares_purchase_id
    # for instance. The problem also manifests itself when using `actions`.
    # This fix is inspired from `auto_link` and https://github.com/activeadmin/activeadmin/issues/279#issuecomment-37366570
    # It works even if its pretty damn weird

    def resource_path(*given_args)
      resource = given_args.first
      config = active_admin_namespace.resource_for(resource.class)
      return unless config

      url_for config.route_instance_path resource, url_options
    end

    def edit_resource_path(*given_args)
      resource = given_args.first
      config = active_admin_namespace.resource_for(resource.class)
      return unless config

      url_for config.route_edit_instance_path resource, url_options
    end
  end
end

# has_many_polymorphic is not used since we removed page builder but left here in case it can be useful someday
class ActiveAdmin::FormBuilder
  def has_many_polymorphic(assoc, options = {}, &block)
    ActiveAdmin::HasManyPolymorphicBuilder.new(self, assoc, options).render(&block)
  end
end

class ActiveAdmin::HasManyPolymorphicBuilder < ActiveAdmin::HasManyBuilder
  def extract_custom_settings!(options)
    super
    @new_records = options.key?(:new_records) ? options.delete(:new_records) : []
    options
  end

  def js_for_has_many(class_string, &form_block)
    assoc_name = assoc_klass.model_name
    placeholder = "NEW_#{assoc_name.to_s.underscore.upcase.tr("/", "_")}_RECORD"

    links = @new_records.map do |config|
      link_text, record = *config

      opts = {
        for: [assoc, record],
        class: class_string,
        for_options: {child_index: placeholder}
      }
      html = template.capture { __getobj__.send(:inputs_for_nested_attributes, opts, &form_block) }

      template.link_to link_text, "#", class: "button has_many_add", data: {
        html: CGI.escapeHTML(html).html_safe, placeholder: placeholder
      }
    end

    links.join("").html_safe
  end
end

# From https://stackoverflow.com/questions/59560189/activeadmin-change-default-sort
ActiveAdmin::Resource.class_eval do
  def sort_order
    @sort_order ||= if resource_class.column_names.include?("updated_at")
      "updated_at_desc"
    else
      # Fallback to default sort if model doesn't have created_at column
      (resource_class.respond_to?(:primary_key) ? resource_class.primary_key.to_s : "id") + "_desc"
    end
  end
end
