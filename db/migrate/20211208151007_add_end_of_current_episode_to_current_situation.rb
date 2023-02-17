class AddEndOfCurrentEpisodeToCurrentSituation < ActiveRecord::Migration[6.1]
  def change
    add_column :current_situations, :end_of_current_episode, :date
  end
end
