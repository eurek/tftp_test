namespace :urls do
  desc "Will go through the database and make sure no internal links remain in text columns, pointing to the wrong env"
  task match_environment: [:environment] do
    # configuration
    IGNORED_TABLES = [
      "ar_internal_metadata",
      "schema_migrations",
      "active_storage_attachments",
      "active_storage_blobs",
      "active_storage_variant_records",
      "pg_search_documents"
    ].freeze

    DOMAINS = {
      test: ["www.example.com:80"],
      development: %w[http://localhost:3000 localhost:3000],
      staging: %w[
        https://staging-time-planet.herokuapp.com
        http://staging-time-planet.herokuapp.com
        staging-time-planet.herokuapp.com
      ],
      production: %w[
        https://www.time-planet.com
        https://time-planet.com
        http://www.time-planet.com
        http://time-planet.com
        www.time-planet.com
        time-planet.com
      ]
    }.freeze
    PREV_DOMAINS = DOMAINS.dup.filter { |k, _| k.to_s != Rails.env }.values.flatten
    CURRENT_DOMAIN = DOMAINS.dup.filter { |k, _| k.to_s == Rails.env }.values&.first&.first

    # logging
    Rails.logger.info "Replacing internal URLs in string and text columns to #{CURRENT_DOMAIN}. Replacing from:"
    PREV_DOMAINS.each do |domain|
      Rails.logger.info "- #{domain}"
    end
    Rails.logger.info ""

    # looping over all models
    result = {}
    models = ActiveRecord::Base.descendants.reject(&:abstract_class).filter(&:table_exists?).sort_by(&:table_name)
    models.each do |model|
      started_at = DateTime.now
      table = model.table_name
      next result[table] = :excluded if IGNORED_TABLES.include?(table)
      next result[table] = :ignored if model.modifiable_columns.empty?

      changed_models_count = 0
      errors_model_ids = []
      model.find_each do |m|
        m.match_url_to_environment(CURRENT_DOMAIN, PREV_DOMAINS)
        next unless m.changed?

        changed_models_count += 1
        m.save
        errors_model_ids.push(m.id) unless m.errors.empty?
      end
      next result[table] = :nothing if changed_models_count.zero?

      result[table] = "#{changed_models_count} out of #{model.count} rows updated"

      unless errors_model_ids.empty?
        result[table] += "; records ids that couldnt be saved because of errors: #{errors_model_ids.join(", ")}"
      end
      puts "#{model} => #{DateTime.now.to_i - started_at.to_i}s D"
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

  desc "Will update service_name on all blob records to match environment storage config"
  task service_match_environment: [:environment] do
    ActiveStorage::Blob.update_all(service_name: Rails.application.config.active_storage.service)
  end
end
