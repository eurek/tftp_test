class AddAddressAndDateOfBirthToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :address, :text
    add_column :users, :zip_code, :string
    add_column :users, :date_of_birth, :date
  end
end
