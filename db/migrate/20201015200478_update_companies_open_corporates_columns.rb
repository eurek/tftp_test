class UpdateCompaniesOpenCorporatesColumns < ActiveRecord::Migration[5.2]
  def up
    rename_column :companies, :open_corporate_company_number, :open_corporates_company_number
    rename_column :companies, :open_corporate_jurisdiction_number, :open_corporates_jurisdiction_code
    change_column :companies, :open_corporates_company_number, :string
  end

  def down
    change_column :companies, :open_corporates_company_number, :integer, using: "nullif(open_corporates_company_number, '')::integer"
    rename_column :companies, :open_corporates_company_number, :open_corporate_company_number
    rename_column :companies, :open_corporates_jurisdiction_code, :open_corporate_jurisdiction_number
  end
end
