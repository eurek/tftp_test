namespace :contents do
  desc "Correct links contained in contents body after signed_id secret changed"
  task correct_images_src: :environment do
    include Rails.application.routes.url_helpers

    Content.joins(:body_attachments_attachments).each do |content|
      I18n.available_locales.each do |locale|
        I18n.locale = locale
        next if content.body(locale: locale).nil?

        parsed_html = Nokogiri::HTML(content.body)
        parsed_html.css("img").each do |image_node|
          next if image_node.attributes["src"].value[/blobs\/(.*?)\//, 1].nil?

          signed_id = if image_node.attributes["src"].value[/blobs\/(.*?)\//, 1].starts_with?("redirect")
            image_node.attributes["src"].value[/redirect\/(.*?)\//, 1]
          else
            image_node.attributes["src"].value[/blobs\/(.*?)\//, 1]
          end

          id = signed_id.split("--")[0]
          id = Base64.strict_decode64(id)
          id = JSON.parse(id).dig("_rails", "message")
          id = Base64.strict_decode64(id)
          id = ActiveStorage::Blob.signed_id_verifier.instance_variable_get(:@serializer).load(id)

          if ActiveStorage::Blob.find_by(id: id).present?
            new_path = rails_blob_path(ActiveStorage::Blob.find(id), only_path: true)
            image_node.attributes["src"].value = new_path
          end
        end
        content.body = parsed_html.at("body").inner_html
      end
      I18n.locale = :fr
      content.save
    end
  end

  desc "Add ® after every mention of Time for the Planet in every content in db"
  task add_brand: :environment do
    IGNORED_TABLES = [
      "ar_internal_metadata",
      "schema_migrations",
      "active_storage_attachments",
      "active_storage_blobs",
      "active_storage_variant_records",
      "pg_search_documents"
    ].freeze

    # logging
    Rails.logger.info "Adding <span class='brand'>®</span> in string or text columns to Time for the Planet occurence."
    Rails.logger.info ""

    # looping over all models
    result = {}
    models = ActiveRecord::Base.descendants.reject(&:abstract_class).filter(&:table_exists?).sort_by(&:table_name)
    models.each do |model|
      table = model.table_name
      next result[table] = :excluded if IGNORED_TABLES.include?(table)
      next result[table] = :ignored if model.modifiable_columns.empty?

      regex = /time for the planet(<span class=('|")brand('|")>®<\/span>)*/i
      text_replacement = 'Time for the Planet<span class="brand">®</span>'

      changed_models = model
        .all
        .each { |m| m.replace_content(regex, text_replacement) }
        .filter(&:changed?)
      next result[table] = :nothing if changed_models.empty?

      changed_models.each(&:save)
      result[table] = "#{changed_models.count} out of #{model.count} rows updated"

      errors_ids = changed_models.reject(&:valid?).map(&:id)
      unless errors_ids.empty?
        result[table] += "; records ids that couldnt be saved because of errors: #{errors_ids.join(", ")}"
      end
    end

    # printing stats
    Rails.logger.info "Excluded tables:"
    result.select { |_, v| v == :excluded }.each { |k, _| Rails.logger.info " - #{k}" }
    Rails.logger.info ""
    Rails.logger.info "Ignored tables (no column had the proper type):"
    result.select { |_, v| v == :ignored }.each { |k, _| Rails.logger.info " - #{k}" }
    Rails.logger.info ""
    Rails.logger.info "Noop tables (no rows to update):"
    result.select { |_, v| v == :nothing }.each { |k, _| Rails.logger.info " - #{k}" }
    Rails.logger.info ""
    Rails.logger.info "Updated tables:"
    result.select { |_, v| v.is_a?(String) }.each { |k, v| Rails.logger.info " - #{k}: #{v}" }
  end
end
