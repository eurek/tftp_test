class AddTitleForCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :title, :string
    add_index :categories, :title, unique: true
  end
end
