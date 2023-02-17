class FixSharesPurchasesAndCompaniesTypos < ActiveRecord::Migration[5.2]
  def change
    rename_column :shares_purchases, :purchase_date, :purchased_at
    rename_column :companies, :open_corporate_juridiction_number, :open_corporate_jurisdiction_number
  end
end
