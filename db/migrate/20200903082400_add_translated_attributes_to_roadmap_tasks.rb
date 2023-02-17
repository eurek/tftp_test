class AddTranslatedAttributesToRoadmapTasks < ActiveRecord::Migration[5.2]
  def change
    add_column :roadmap_tasks, :title_i18n, :jsonb, default: {}
    add_column :roadmap_tasks, :text_i18n, :jsonb, default: {}
  end
end
