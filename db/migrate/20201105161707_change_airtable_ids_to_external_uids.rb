class ChangeAirtableIdsToExternalUids < ActiveRecord::Migration[5.2]
  def change
    rename_column :badges, :airtable_id, :external_uid
    rename_column :roles, :airtable_id, :external_uid
    rename_column :users, :airtable_id, :external_uid
  end
end
