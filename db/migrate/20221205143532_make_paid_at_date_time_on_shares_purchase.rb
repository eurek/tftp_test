class MakePaidAtDateTimeOnSharesPurchase < ActiveRecord::Migration[6.1]
  def change
    change_column :shares_purchases, :paid_at, :datetime
  end
end
