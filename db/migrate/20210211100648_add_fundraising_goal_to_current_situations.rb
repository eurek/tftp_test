class AddFundraisingGoalToCurrentSituations < ActiveRecord::Migration[5.2]
  def change
    add_column :current_situations, :fundraising_goal, :integer, null: false, default: 5_000_000
  end
end
