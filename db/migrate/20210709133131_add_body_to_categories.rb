class AddBodyToCategories < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :body_i18n, :jsonb, default: {}
  end
end
