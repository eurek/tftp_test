class CreateRoadmapTasks < ActiveRecord::Migration[5.2]
  def change
    create_table :roadmap_tasks do |t|
      t.string :title
      t.text :text
      t.datetime :done_at, default: nil
      t.string :estimated_completion
      t.string :duration_type
      t.string :task_category

      t.timestamps
    end
  end
end
