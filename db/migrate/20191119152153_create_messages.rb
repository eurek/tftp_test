class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :sender_first_name
      t.string :sender_last_name
      t.string :sender_email
      t.text :body

      t.timestamps
    end
  end
end
