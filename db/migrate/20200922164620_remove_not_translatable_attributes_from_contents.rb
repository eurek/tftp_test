class RemoveNotTranslatableAttributesFromContents < ActiveRecord::Migration[5.2]
  def change
    remove_column :contents, :title, :string
    remove_column :contents, :slug, :string
    remove_column :contents, :meta_title, :string
    remove_column :contents, :meta_description, :string
    remove_column :contents, :body, :text
    remove_column :contents, :cover_image_alt, :string
    remove_column :contents, :short_title, :string
  end
end
