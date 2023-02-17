class AddPositionAndStatusOnRoadmapTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :roadmap_tasks, :position, :integer
    add_column :roadmap_tasks, :status, :string, default: "to_do"
    rename_column :roadmap_tasks, :task_category, :category
  end
end
