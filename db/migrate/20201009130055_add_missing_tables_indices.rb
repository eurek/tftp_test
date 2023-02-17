class AddMissingTablesIndices < ActiveRecord::Migration[5.2]
  def change
    # where/find_by
    add_index :roadmap_tasks, :status
    add_index :roadmap_tasks, :category
    add_index :roadmap_tasks, :duration_type
    add_index :categories, :published
    add_index :pages, :slug

    # prismic id
    add_index :call_to_actions, :prismic_id
    add_index :categories, :prismic_id
    add_index :contents, :prismic_id
    add_index :entrepreneurs, :prismic_id
    add_index :tags, :prismic_id
    add_index :projects, :prismic_id
    add_index :highlighted_contents, :prismic_id

    # has_many
    add_index :prerequisites, :dependent_id
    add_index :prerequisites, :necessary_id
  end
end
