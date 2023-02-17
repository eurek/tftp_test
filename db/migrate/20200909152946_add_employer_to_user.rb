class AddEmployerToUser < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :employer, foreign_key: {to_table: :companies}
  end
end
