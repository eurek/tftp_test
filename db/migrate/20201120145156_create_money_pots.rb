class CreateMoneyPots < ActiveRecord::Migration[5.2]
  def change
    create_table :money_pots do |t|
      t.belongs_to :user
      t.integer    :goal
      t.timestamps
    end
  end
end
