class AddTranslatedAttributesOnCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :name_i18n, :jsonb, default: {}
    add_column :categories, :slug_i18n, :jsonb, default: {}
    add_column :categories, :meta_title_i18n, :jsonb, default: {}
    add_column :categories, :meta_description_i18n, :jsonb, default: {}
    add_column :categories, :description_i18n, :jsonb, default: {}
  end
end
