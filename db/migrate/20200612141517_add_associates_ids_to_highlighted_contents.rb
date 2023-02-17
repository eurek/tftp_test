class AddAssociatesIdsToHighlightedContents < ActiveRecord::Migration[5.2]
  def change
    add_column :highlighted_contents, :associates, :string, array: true, default: []
  end
end
