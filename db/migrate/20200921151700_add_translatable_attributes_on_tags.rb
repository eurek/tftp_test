class AddTranslatableAttributesOnTags < ActiveRecord::Migration[5.2]
  def change
    add_column :tags, :name_i18n, :jsonb, default: {}
    add_column :tags, :slug_i18n, :jsonb, default: {}
    add_column :tags, :meta_title_i18n, :jsonb, default: {}
    add_column :tags, :meta_description_i18n, :jsonb, default: {}
    add_column :tags, :text_i18n, :jsonb, default: {}
  end
end
