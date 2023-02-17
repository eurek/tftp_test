class RenamePurchasedAtInSharesPurchases < ActiveRecord::Migration[6.1]
  def change
    rename_column :shares_purchases, :purchased_at, :completed_at
  end
end
