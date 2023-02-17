class AddIndexOnUsersCreatedAt < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :created_at
    add_index :companies, :created_at
  end
end
