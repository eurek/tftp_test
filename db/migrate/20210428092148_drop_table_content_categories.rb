class DropTableContentCategories < ActiveRecord::Migration[5.2]
  def self.up
    drop_table :content_categories
  end

  def self.down
    create_table :content_categories do |t|
      t.belongs_to :content, index: true
      t.belongs_to :category, index: true

      t.timestamps
    end
  end
end
