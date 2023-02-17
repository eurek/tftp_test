class AddIndexesOnUsersAndCompanies < ActiveRecord::Migration[5.2]
  def change
    add_index :users, :is_displayed, where: 'is_displayed'
    add_index :companies, :is_displayed, where: 'is_displayed'
  end
end
