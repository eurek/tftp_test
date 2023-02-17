class RemoveAssociatesFromHighlightedContents < ActiveRecord::Migration[5.2]
  def change
    remove_column :highlighted_contents, :associates, :string, array: true
  end
end
