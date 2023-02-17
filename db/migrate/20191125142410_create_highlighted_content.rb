class CreateHighlightedContent < ActiveRecord::Migration[5.2]
  def change
    create_table :highlighted_contents do |t|
      t.string :prismic_id
      t.boolean :published, default: false
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
