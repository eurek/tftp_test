class CreatePageSections < ActiveRecord::Migration[5.2]
  def change
    create_table :page_sections do |t|
      t.references :page, null: false, index: false
      t.integer :position, default: 0, null: false
      t.string :type
      t.jsonb :title_i18n, default: {}
      t.jsonb :text_i18n, default: {}
    end
  end
end
