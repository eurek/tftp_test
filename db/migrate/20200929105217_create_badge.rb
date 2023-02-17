class CreateBadge < ActiveRecord::Migration[5.2]
  def change
    create_table :badges do |t|
      t.text :description
      t.text :fun_description
      t.string :notification_message

      t.timestamps
    end
  end
end
