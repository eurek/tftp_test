class UpdateBadgesAttributes < ActiveRecord::Migration[5.2]
  def change
    add_column :badges, :name, :string
    add_column :badges, :position, :integer, null: false, default: 0
    remove_column :badges, :notification_message, :string
  end
end
