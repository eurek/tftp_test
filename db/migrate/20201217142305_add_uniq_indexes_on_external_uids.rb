class AddUniqIndexesOnExternalUids < ActiveRecord::Migration[5.2]
  def change
    add_index :badges, :external_uid, unique: true
    add_index :users, :external_uid, unique: true
    add_index :roles, :external_uid, unique: true
  end
end
