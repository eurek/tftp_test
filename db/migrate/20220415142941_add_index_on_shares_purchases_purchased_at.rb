class AddIndexOnSharesPurchasesPurchasedAt < ActiveRecord::Migration[6.1]
  def change
    add_index :shares_purchases, :purchased_at
  end
end
