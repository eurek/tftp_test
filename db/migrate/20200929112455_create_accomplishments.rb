class CreateAccomplishments < ActiveRecord::Migration[5.2]
  def change
    create_table :accomplishments do |t|
      t.references :badge, index: true, null: false

      t.timestamps
    end
  end
end
