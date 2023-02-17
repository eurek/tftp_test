class AddAirtableIdToBadgesAndRoles < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :airtable_id, :string
    add_column :roles, :airtable_id, :string
  end
end
