class RemoveTablesFoundersAndInnovationInventions < ActiveRecord::Migration[6.1]
  def self.up
    drop_table :innovation_inventions
    drop_table :founders
    add_column :innovations, :founders, :string, array: true
  end

  def self.down
    remove_column :innovations, :founders, :string, array: true
    create_table :founders do |t|
      t.string :full_name, null: false

      t.timestamps
    end

    create_table :innovation_inventions do |t|
      t.references :founder, foreign_key: true
      t.references :innovation, foreign_key: true

      t.timestamps
    end
  end
end
