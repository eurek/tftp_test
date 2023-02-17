class RemoveTextAndMetaFromTags < ActiveRecord::Migration[5.2]
  def change
    remove_column :tags, :meta_title_i18n, :jsonb, default: {}
    remove_column :tags, :meta_description_i18n, :jsonb, default: {}
    remove_column :tags, :text_i18n, :jsonb, default: {}
  end
end
