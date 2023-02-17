class RemoveOldAssociateIdsFromHighlightedContent < ActiveRecord::Migration[5.2]
  def change
    remove_column :highlighted_contents, :associate_ids, :bigint, default: [], array: true
  end
end
