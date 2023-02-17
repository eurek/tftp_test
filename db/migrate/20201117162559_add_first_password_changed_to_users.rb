class AddFirstPasswordChangedToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :first_password_changed, :boolean, default: false
  end
end
