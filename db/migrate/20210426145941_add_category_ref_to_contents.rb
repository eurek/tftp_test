class AddCategoryRefToContents < ActiveRecord::Migration[5.2]
  def change
    add_reference :contents, :category, foreign_key: true
  end
end
