class AddUniqConstraintOnInnovationsExternalUid < ActiveRecord::Migration[6.1]
  def change
    add_index :innovations, :external_uid, unique: true
  end
end
