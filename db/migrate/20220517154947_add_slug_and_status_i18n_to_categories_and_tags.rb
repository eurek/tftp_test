class AddSlugAndStatusI18nToCategoriesAndTags < ActiveRecord::Migration[6.1]
  def change
    add_column :categories, :slug, :string
    add_column :categories, :published_i18n, :jsonb, default: {}
    remove_column :categories, :published, :boolean

    add_column :tags, :slug, :string
    add_column :tags, :published_i18n, :jsonb, default: {}
    remove_column :tags, :published, :boolean

    rename_column :contents, :new_slug, :slug
  end
end
