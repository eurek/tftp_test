class AddExternalUidOnSharesPurchase < ActiveRecord::Migration[5.2]
  def change
    add_column :shares_purchases, :external_uid, :string
    add_index :shares_purchases, :external_uid, unique: true
  end
end
