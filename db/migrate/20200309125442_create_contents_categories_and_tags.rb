class CreateContentsCategoriesAndTags < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :prismic_id
      t.string :slug
      t.string :name
      t.string :meta_title
      t.string :meta_description
      t.text :description
      t.boolean :published, default: false

      t.timestamps
    end

    create_table :tags do |t|
      t.string :prismic_id
      t.string :slug
      t.string :name
      t.string :meta_title
      t.string :meta_description
      t.text :text
      t.boolean :published, default: false
      t.references :category, foreign_key: true

      t.timestamps
    end

    create_table :contents do |t|
      t.string :prismic_id
      t.string :slug
      t.string :title
      t.string :meta_title
      t.string :meta_description
      t.text :body
      t.string :cover_image_url
      t.string :cover_image_alt
      t.boolean :published, default: false
      t.references :tag, foreign_key: true

      t.timestamps
    end

    create_table :content_categories do |t|
      t.belongs_to :content, index: true
      t.belongs_to :category, index: true

      t.timestamps
    end

    create_table :content_tags do |t|
      t.belongs_to :content, index: true
      t.belongs_to :tag, index: true

      t.timestamps
    end
  end
end
