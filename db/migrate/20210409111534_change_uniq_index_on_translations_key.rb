class ChangeUniqIndexOnTranslationsKey < ActiveRecord::Migration[5.2]
  def change
    remove_index :translations, ["locale", "key"]
    add_index :translations, :key, unique: true
    remove_column :translations, :value, :text
    remove_column :translations, :locale, :string
    remove_column :translations, :interpolations, :text
    remove_column :translations, :is_proc, :boolean
  end
end
