class AddBlogAndMediaToHighlightedContents < ActiveRecord::Migration[5.2]
  def change
    add_column :highlighted_contents, :blog_content_id_i18n, :jsonb, default: {}
    add_column :highlighted_contents, :time_media_content_id_i18n, :jsonb, default: {}
  end
end
