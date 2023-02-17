class AddNewTextsToPageSections < ActiveRecord::Migration[5.2]
  def change
    rename_column :page_sections, :text_i18n, :text_1_i18n
    add_column :page_sections, :text_2_i18n, :jsonb, default: {}
    add_column :page_sections, :text_3_i18n, :jsonb, default: {}
    add_column :page_sections, :text_4_i18n, :jsonb, default: {}
    add_column :page_sections, :text_5_i18n, :jsonb, default: {}
    add_column :page_sections, :subtitle_i18n, :jsonb, default: {}
  end
end
