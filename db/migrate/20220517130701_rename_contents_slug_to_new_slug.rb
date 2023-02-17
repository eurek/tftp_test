class RenameContentsSlugToNewSlug < ActiveRecord::Migration[6.1]
  def change
    rename_column :contents, :slug, :new_slug
  end
end
