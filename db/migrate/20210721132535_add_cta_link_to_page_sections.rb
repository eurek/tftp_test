class AddCtaLinkToPageSections < ActiveRecord::Migration[5.2]
  def change
    add_column :page_sections, :cta_link_i18n, :jsonb, default: {}
  end
end
