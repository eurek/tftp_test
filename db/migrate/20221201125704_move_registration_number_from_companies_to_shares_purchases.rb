class MoveRegistrationNumberFromCompaniesToSharesPurchases < ActiveRecord::Migration[6.1]
  def change
    remove_column :companies, :registration_number, :string
    add_column :shares_purchases, :company_registration_number, :string
    add_column :shares_purchases, :payment_status, :string, null: false, default: "pending"
    add_column :shares_purchases, :official_date, :date
    remove_column :shares_purchases, :status, :string
    add_column :shares_purchases, :status, :string, null: false, default: "pending"
    add_column :shares_purchases, :sponsor, :boolean, null: false, default: false
  end
end
