class DropTableMessages < ActiveRecord::Migration[5.2]
  def self.up
    drop_table :messages
  end

  def self.down
    create_table :messages do |t|
      t.string :sender_first_name
      t.string :sender_last_name
      t.string :sender_email
      t.string :sender_phone
      t.boolean :interested_to_invest, default: false
      t.text :body

      t.timestamps
    end
  end
end
