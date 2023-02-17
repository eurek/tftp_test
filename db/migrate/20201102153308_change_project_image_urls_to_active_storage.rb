class ChangeProjectImageUrlsToActiveStorage < ActiveRecord::Migration[5.2]
  def change
    remove_column :projects, :cover_image_url, :string
    remove_column :projects, :secondary_image_1_url, :string
    remove_column :projects, :secondary_image_2_url, :string
    remove_column :projects, :project_logo_url, :string
  end
end
