class RemoveEstimatedCompletionOnRoadmapTasks < ActiveRecord::Migration[5.2]
  def change
    remove_column :roadmap_tasks, :estimated_completion, :string
  end
end
