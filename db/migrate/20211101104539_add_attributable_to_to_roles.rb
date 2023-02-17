class AddAttributableToToRoles < ActiveRecord::Migration[6.1]
  def change
    add_column :roles, :attributable_to, :string
  end
end
