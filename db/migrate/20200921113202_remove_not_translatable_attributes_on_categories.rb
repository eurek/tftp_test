class RemoveNotTranslatableAttributesOnCategories < ActiveRecord::Migration[5.2]
  def change
    remove_column :categories, :name, :string
    remove_column :categories, :slug, :string
    remove_column :categories, :meta_title, :string
    remove_column :categories, :meta_description, :string
    remove_column :categories, :description, :text
  end
end
