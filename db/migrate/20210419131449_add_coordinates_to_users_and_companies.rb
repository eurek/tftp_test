class AddCoordinatesToUsersAndCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :latitude, :float
    add_column :users, :longitude, :float
    add_column :companies, :latitude, :float
    add_column :companies, :longitude, :float
  end
end
