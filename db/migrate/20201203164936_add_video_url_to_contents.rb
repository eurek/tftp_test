class AddVideoUrlToContents < ActiveRecord::Migration[5.2]
  def change
    add_column :contents, :video_url, :string
  end
end
