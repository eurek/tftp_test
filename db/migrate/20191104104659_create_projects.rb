class CreateProjects < ActiveRecord::Migration[5.2]
  def change
    create_table :projects do |t|
      t.string :prismic_id
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
      t.string :cover_image_url
      t.string :cover_image_alt
      t.string :secondary_image_1_url
      t.string :secondary_image_1_alt
      t.string :secondary_image_2_url
      t.string :secondary_image_2_alt
      t.string :project_logo_url
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
  end
end
