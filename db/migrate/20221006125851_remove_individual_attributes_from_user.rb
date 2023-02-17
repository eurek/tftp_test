class RemoveIndividualAttributesFromUser < ActiveRecord::Migration[6.1]
  def change
    rename_column :individuals, :linkedin_url, :linkedin
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    remove_column :users, :phone, :string
    remove_column :users, :date_of_birth, :date
    remove_column :users, :address, :text
    remove_column :users, :city, :string
    remove_column :users, :zip_code, :string
    remove_column :users, :country, :string
    remove_column :users, :linkedin, :string
    remove_column :users, :latitude, :float
    remove_column :users, :longitude, :float

    remove_reference :users, :employer
  end
end
