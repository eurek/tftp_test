class RemoveTitleAndTextFromRoadmapTasks < ActiveRecord::Migration[5.2]
  def change
    remove_column :roadmap_tasks, :title, :string
    remove_column :roadmap_tasks, :text, :text
  end
end
