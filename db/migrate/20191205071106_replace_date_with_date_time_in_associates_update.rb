class ReplaceDateWithDateTimeInAssociatesUpdate < ActiveRecord::Migration[5.2]
  def up
    change_column :associates_updates, :last_associate_date_1, :datetime
    change_column :associates_updates, :last_associate_date_2, :datetime
    change_column :associates_updates, :last_associate_date_3, :datetime
  end

  def down
    change_column :associates_updates, :last_associate_date_1, :date
    change_column :associates_updates, :last_associate_date_2, :date
    change_column :associates_updates, :last_associate_date_3, :date
  end
end
