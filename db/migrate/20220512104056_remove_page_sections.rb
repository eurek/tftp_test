class RemovePageSections < ActiveRecord::Migration[6.1]
  def self.up
    drop_table :page_sections
  end

  def self.down
    create_table :page_sections do |t|
      t.references :page, null: false, index: false
      t.integer :position, default: 0, null: false
      t.string :type
      t.jsonb :title_i18n, default: {}
      t.jsonb :image_alt_i18n, default: {}
      t.string :color
      t.string :layout
      t.jsonb :text_1_i18n, default: {}
      t.jsonb :text_2_i18n, default: {}
      t.jsonb :text_3_i18n, default: {}
      t.jsonb :text_4_i18n, default: {}
      t.jsonb :text_5_i18n, default: {}
      t.jsonb :subtitle_i18n, default: {}
      t.jsonb :cta_link_i18n, default: {}
    end
  end
end
