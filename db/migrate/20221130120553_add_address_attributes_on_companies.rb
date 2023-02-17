class AddAddressAttributesOnCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :city, :string
    add_column :companies, :zip_code, :string
    add_column :companies, :street_address, :text
  end
end
