class AddCountryToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :country, :string
  end
end
