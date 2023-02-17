class AddZohoSignRequestIdToSharesPurchases < ActiveRecord::Migration[6.1]
  def change
    add_column :shares_purchases, :zoho_sign_request_id, :string
    add_index :shares_purchases, :zoho_sign_request_id, unique: true
  end
end
