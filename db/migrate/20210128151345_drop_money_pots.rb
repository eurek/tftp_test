class DropMoneyPots < ActiveRecord::Migration[5.2]
  def self.up
    remove_reference :shares_purchases, :money_pot, foreign_key: true
    drop_table :money_pots
  end

  def self.down
    create_table :money_pots do |t|
      t.belongs_to :user
      t.integer    :goal
      t.timestamps
    end

    add_reference :shares_purchases, :money_pot, foreign_key: true
  end
end
