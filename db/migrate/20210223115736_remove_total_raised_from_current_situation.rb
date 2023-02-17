class RemoveTotalRaisedFromCurrentSituation < ActiveRecord::Migration[5.2]
  def up
    remove_column :current_situations, :total_raised
  end

  def down
    add_column :current_situations, :total_raised, :integer
  end
end
