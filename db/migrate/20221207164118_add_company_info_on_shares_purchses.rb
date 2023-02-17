class AddCompanyInfoOnSharesPurchses < ActiveRecord::Migration[6.1]
  def change
    add_column :shares_purchases, :company_info, :jsonb
    remove_column :shares_purchases, :company_registration_number, :string
  end
end
