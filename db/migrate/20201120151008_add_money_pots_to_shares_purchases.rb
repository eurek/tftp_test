class AddMoneyPotsToSharesPurchases < ActiveRecord::Migration[5.2]
  def change
    add_reference :shares_purchases, :money_pot, foreign_key: true
  end
end
