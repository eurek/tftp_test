class AddValueI18nToTranslations < ActiveRecord::Migration[5.2]
  def change
    add_column :translations, :value_i18n, :jsonb, default: {}
  end
end
