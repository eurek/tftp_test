class AddRoleAttributions < ActiveRecord::Migration[5.2]
  def change
    create_table :role_attributions do |t|
      t.belongs_to :role
      t.belongs_to :user

      t.timestamps
    end
  end
end
