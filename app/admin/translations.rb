ActiveAdmin.register Translation do
  menu parent: :static_pages, priority: 2

  permit_params :locale, :key, :value
  actions :all, except: [:destroy]

  filter :key
  filter :value
  filter :key_starts_with, label: "Category", as: :select, collection: proc { Translation.translated_pages }

  scope :all, default: true
  scope "Not translated" do |scope|
    scope.where("value_i18n -> ? IS NULL", I18n.locale)
  end
  scope "Already Translated" do |scope|
    scope.where("value_i18n -> ? IS NOT NULL", I18n.locale)
  end

  index do
    selectable_column
    id_column
    column :key
    column_without_fallback :value

    unless I18n.locale == :fr
      column "Value Fr" do |translation|
        translation.value(locale: :fr)
      end
    end

    column "Translated" do |translation|
      translation.value(fallback: false).present?
    end
    column :created_at
    column :updated_at

    actions
  end

  csv do
    column :id
    column :key
    column :created_at
    column :updated_at
    I18n.available_locales.each do |locale|
      column("Value #{locale}") { |translation| translation.value_i18n[locale] }
    end
  end

  show do
    attributes_table do
      row :key
      row_without_fallback :value
    end

    attributes_table title: "In other languages" do
      I18n.available_locales.each do |locale|
        row "value #{I18n.t("common.language", locale: locale)}" do |translation|
          translation.value(locale: locale)
        end
      end
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    adapt_input_height = 'this.style.height = "";this.style.height = this.scrollHeight + "px"'
    should_format_json = f.object.value(fallback: false).present? &&
      !f.object.value(fallback: false).is_a?(String) &&
      object.errors[:value].empty?

    f.inputs do
      f.input :key, input_html: {readonly: true}
      f.input :value, as: :text, label: "Value (#{I18n.t("common.language")})", input_html: {
        value: should_format_json ?
          JSON.pretty_generate(f.object.value(fallback: false) || "") :
          f.object.value(fallback: false),
        onfocus: adapt_input_height,
        oninput: adapt_input_height,
        rows: ""
      }
      [:fr, :en].each do |locale|
        f.input "reference_#{locale}",
          as: :text,
          input_html: {
            value: !f.object.value(locale: locale).is_a?(String) ?
              JSON.pretty_generate(f.object.value(locale: locale) || "") :
              f.object.value(locale: locale),
            readonly: true,
            onfocus: adapt_input_height,
            rows: ""
          }
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
