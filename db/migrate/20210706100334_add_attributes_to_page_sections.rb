class AddAttributesToPageSections < ActiveRecord::Migration[5.2]
  def change
    add_column :page_sections, :image_alt_i18n, :jsonb, default: {}
    add_column :page_sections, :color, :string
    add_column :page_sections, :layout, :string
  end
end
