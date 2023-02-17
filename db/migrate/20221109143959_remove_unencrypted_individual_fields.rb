class RemoveUnencryptedIndividualFields < ActiveRecord::Migration[6.1]
  def change
    remove_column :individuals, :first_name, :string
    remove_column :individuals, :last_name, :string
    remove_column :individuals, :email, :string
    remove_column :individuals, :phone, :string
    remove_column :individuals, :date_of_birth, :date
    remove_column :individuals, :address, :text
    remove_column :individuals, :latitude, :float
    remove_column :individuals, :longitude, :float
    remove_column :individuals, :linkedin, :string
    remove_column :individuals, :description, :text
  end
end
