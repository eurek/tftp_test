class AddTranslatableAttributesOnBadges < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :description_i18n, :jsonb, default: {}
    add_column :badges, :fun_description_i18n, :jsonb, default: {}
    add_column :badges, :name_i18n, :jsonb, default: {}
  end
end
