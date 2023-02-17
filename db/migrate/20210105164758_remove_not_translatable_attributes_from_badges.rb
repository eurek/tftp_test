class RemoveNotTranslatableAttributesFromBadges < ActiveRecord::Migration[5.2]
  def change
    remove_column :badges, :description, :text
    remove_column :badges, :fun_description, :text
    remove_column :badges, :name, :string
  end
end
