class AddTranslatableAttributesOnContents < ActiveRecord::Migration[5.2]
  def change
    add_column :contents, :title_i18n, :jsonb, default: {}
    add_column :contents, :slug_i18n, :jsonb, default: {}
    add_column :contents, :meta_title_i18n, :jsonb, default: {}
    add_column :contents, :meta_description_i18n, :jsonb, default: {}
    add_column :contents, :body_i18n, :jsonb, default: {}
    add_column :contents, :cover_image_alt_i18n, :jsonb, default: {}
    add_column :contents, :short_title_i18n, :jsonb, default: {}
  end
end
