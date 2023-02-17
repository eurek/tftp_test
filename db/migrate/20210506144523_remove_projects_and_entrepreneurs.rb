class RemoveProjectsAndEntrepreneurs < ActiveRecord::Migration[5.2]
  def self.up
    remove_reference :highlighted_contents, :project, index: true, foreign_key: true
    drop_table :problems_projects
    drop_table :projects
    drop_table :entrepreneurs
  end

  def self.down
    create_table :projects do |t|
      t.string :slug
      t.string :title
      t.string :meta_title
      t.string :meta_description
      t.string :project_url
      t.string :funding_status
      t.string :long_summary
      t.string :short_summary
      t.text :description
      t.string :quote
      t.string :cover_image_alt
      t.string :secondary_image_1_alt
      t.string :secondary_image_2_alt
      t.string :project_logo_alt
      t.string :keyword_1
      t.string :icon_1
      t.string :keyword_2
      t.string :icon_2
      t.string :keyword_3
      t.string :icon_3
      t.string :keyword_4
      t.string :icon_4
      t.boolean :published, default: false

      t.timestamps
    end

    create_table :entrepreneurs do |t|
      t.string :name
      t.string :position
      t.string :description
      t.string :picture_alt
      t.belongs_to :project, index: true
      t.boolean :published, default: false

      t.timestamps
    end

    add_reference :highlighted_contents, :project, index: true, foreign_key: true

    create_join_table :problems, :projects do |t|
      t.references :problem, foreign_key: true
      t.references :project, foreign_key: true
    end
  end
end
