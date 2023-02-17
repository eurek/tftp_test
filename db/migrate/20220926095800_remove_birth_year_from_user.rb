class RemoveBirthYearFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :birth_year, :integer
  end
end
