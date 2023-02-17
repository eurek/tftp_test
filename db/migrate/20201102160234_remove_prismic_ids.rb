class RemovePrismicIds < ActiveRecord::Migration[5.2]
  def change
    remove_index :call_to_actions, :prismic_id
    remove_index :categories, :prismic_id
    remove_index :contents, :prismic_id
    remove_index :entrepreneurs, :prismic_id
    remove_index :tags, :prismic_id
    remove_index :projects, :prismic_id
    remove_index :highlighted_contents, :prismic_id

    remove_column :call_to_actions, :prismic_id, :string
    remove_column :categories, :prismic_id, :string
    remove_column :contents, :prismic_id, :string
    remove_column :entrepreneurs, :prismic_id, :string
    remove_column :highlighted_contents, :prismic_id, :string
    remove_column :projects, :prismic_id, :string
    remove_column :tags, :prismic_id, :string
  end
end
