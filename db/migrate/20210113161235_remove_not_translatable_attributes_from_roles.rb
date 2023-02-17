class RemoveNotTranslatableAttributesFromRoles < ActiveRecord::Migration[5.2]
  def change
    remove_column :roles, :description, :text
    remove_column :roles, :name, :string
  end
end
