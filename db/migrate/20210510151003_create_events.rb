class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :title
      t.string :locale
      t.string :category
      t.text :description
      t.datetime :date
      t.string :venue
      t.string :registration_link
      t.string :external_uid

      t.timestamps
    end
    add_index :events, :external_uid, unique: true
  end
end
