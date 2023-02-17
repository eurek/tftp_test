class RemoveNotTranslatableAttributesFromTags < ActiveRecord::Migration[5.2]
  def change
    remove_column :tags, :name, :string
    remove_column :tags, :slug, :string
    remove_column :tags, :meta_title, :string
    remove_column :tags, :meta_description, :string
    remove_column :tags, :text, :text
  end
end
