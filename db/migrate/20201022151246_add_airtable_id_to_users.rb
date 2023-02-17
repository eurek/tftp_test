class AddAirtableIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :airtable_id, :string
    add_column :users, :pending, :boolean, default: true
  end
end
