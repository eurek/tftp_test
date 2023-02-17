class CreateTemporaryBanners < ActiveRecord::Migration[6.1]
  def change
    create_table :temporary_banners do |t|
      t.jsonb :headline_i18n, default: {}
      t.jsonb :cta_i18n, default: {}
      t.jsonb :link_i18n, default: {}
      t.jsonb :is_displayed_i18n, default: {}

      t.timestamps
    end
  end
end
