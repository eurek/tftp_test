class AddPositionOnRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :roles, :position, :integer, null: false, default: 0
  end
end
