class AddSomeAttributesToCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :companies, :registration_number, :string
    add_column :companies, :legal_form, :string
    add_column :companies, :structure_size, :string
  end
end
