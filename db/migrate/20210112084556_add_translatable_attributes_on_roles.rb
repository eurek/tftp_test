class AddTranslatableAttributesOnRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :name_i18n, :jsonb, default: {}
    add_column :roles, :description_i18n, :jsonb, default: {}
  end
end
