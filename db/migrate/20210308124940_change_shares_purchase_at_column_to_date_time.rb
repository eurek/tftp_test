class ChangeSharesPurchaseAtColumnToDateTime < ActiveRecord::Migration[5.2]
  def up
    change_column :shares_purchases, :purchased_at, :datetime
  end

  def down
    change_column :shares_purchases, :purchased_at, :date
  end
end
