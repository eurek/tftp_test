class ChangeEntrepreneurImageUrlsToActiveStorage < ActiveRecord::Migration[5.2]
  def change
    remove_column :entrepreneurs, :picture_url, :string
  end
end
