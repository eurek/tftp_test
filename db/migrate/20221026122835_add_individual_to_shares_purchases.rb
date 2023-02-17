class AddIndividualToSharesPurchases < ActiveRecord::Migration[6.1]
  def change
    add_reference :shares_purchases, :individual
  end
end
