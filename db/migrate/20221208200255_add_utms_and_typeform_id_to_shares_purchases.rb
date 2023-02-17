class AddUtmsAndTypeformIdToSharesPurchases < ActiveRecord::Migration[6.1]
  def change
    add_column :shares_purchases, :utm_source, :string
    add_column :shares_purchases, :utm_medium, :string
    add_column :shares_purchases, :utm_campaign, :string
    add_column :shares_purchases, :typeform_id, :string
  end
end
