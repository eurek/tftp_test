class RemoveTagReferenceFromContents < ActiveRecord::Migration[5.2]
  def change
    remove_reference :contents, :tag, index: true, foreign_key: true
  end
end
