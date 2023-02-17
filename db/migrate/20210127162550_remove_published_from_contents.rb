class RemovePublishedFromContents < ActiveRecord::Migration[5.2]
  def change
    remove_column :contents, :published, :boolean
  end
end
