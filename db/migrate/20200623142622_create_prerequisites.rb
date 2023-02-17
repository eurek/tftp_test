class CreatePrerequisites < ActiveRecord::Migration[5.2]
  def change
    create_table :prerequisites do |t|
      t.integer :dependent_id
      t.integer :necessary_id

      t.timestamps
    end
  end
end
