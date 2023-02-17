class CreateAssociatesUpdates < ActiveRecord::Migration[5.2]
  def change
    create_table :associates_updates do |t|
      t.integer :total_raised
      t.integer :total_associates
      t.string :last_associate_name_1
      t.integer :last_associate_shares_1
      t.date :last_associate_date_1
      t.string :last_associate_name_2
      t.integer :last_associate_shares_2
      t.date :last_associate_date_2
      t.string :last_associate_name_3
      t.integer :last_associate_shares_3
      t.date :last_associate_date_3
    end
  end
end
