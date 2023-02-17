class RemoveEndOfCurrentEpisodeFundraisingGoalAndEnterprisesCreatedFromCurrentSituation < ActiveRecord::Migration[6.1]
  def change
    remove_column :current_situations, :fundraising_goal, :integer
    remove_column :current_situations, :end_of_current_episode, :date
    remove_column :current_situations, :enterprises_created, :integer
  end
end
