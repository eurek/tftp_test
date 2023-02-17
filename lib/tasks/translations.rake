namespace :translations do
  desc "This tasks browses fr yml files and saves their content in translations table in db"
  task load_yml_files: [:environment] do
    backend = I18n.backend
    backend = backend.backends.find { |b| b.is_a?(I18n::Backend::ActiveRecord) } if backend.is_a?(I18n::Backend::Chain)
    excluded_files = %w[kaminari routes]
    locales_folder = Rails.root + "config/locales"
    files = locales_folder
      .children.select(&:file?)
      .select { |path| path.extname == ".yml" }
      .reject { |path| excluded_files.find { |f| path.to_s.include?(f) }.present? }
      .reject { |path| !path.to_s.include?("fr") }
    saved_keys = []
    files.each do |file|
      Rails.logger.info "--- Loading translations from #{file.basename} into DB ---"
      content = YAML.load_file(file)
      locale = content.keys.first
      saved_keys += backend.flatten_translations(locale, content[locale], true, false).keys
      backend.store_translations(locale, content[locale], create_only: true)
    end
    old_translations = Translation.where.not(key: saved_keys)
    Rails.logger.info "Removing old keys: #{old_translations.pluck(:key)}"
    old_translations.destroy_all
  end
end
