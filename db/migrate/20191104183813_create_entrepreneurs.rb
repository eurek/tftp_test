class CreateEntrepreneurs < ActiveRecord::Migration[5.2]
  def change
    create_table :entrepreneurs do |t|
      t.string :prismic_id
      t.string :name
      t.string :position
      t.string :description
      t.string :picture_url
      t.string :picture_alt
      t.belongs_to :project, index: true
      t.boolean :published, default: false

      t.timestamps
    end
  end
end
