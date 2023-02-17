class AddIsADuplicateToSharesPurchases < ActiveRecord::Migration[6.1]
  def change
    add_column :shares_purchases, :is_a_duplicate, :boolean, null: false, default: false
  end
end
