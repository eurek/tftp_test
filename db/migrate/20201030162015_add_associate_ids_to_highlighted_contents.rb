class AddAssociateIdsToHighlightedContents < ActiveRecord::Migration[5.2]
  def change
    add_column :highlighted_contents, :associate_ids, :bigint, default: [], array: true
  end
end
