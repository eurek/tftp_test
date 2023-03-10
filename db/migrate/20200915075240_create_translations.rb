class CreateTranslations < ActiveRecord::Migration[5.2]
  def self.up
    create_table :translations do |t|
      t.string :locale
      t.string :key
      t.text :value
      t.text :interpolations
      t.boolean :is_proc, :default => false

      t.timestamps
    end
    add_index :translations, [:locale, :key], unique: true
  end

  def self.down
    drop_table :translations
  end
end
