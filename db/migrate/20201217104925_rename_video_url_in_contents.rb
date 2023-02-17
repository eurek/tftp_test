class RenameVideoUrlInContents < ActiveRecord::Migration[5.2]
  def change
    rename_column :contents, :video_url, :youtube_video_id
  end
end
