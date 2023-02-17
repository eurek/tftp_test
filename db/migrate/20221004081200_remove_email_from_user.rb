class RemoveEmailFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :email, null: false, default: ""
  end
end
