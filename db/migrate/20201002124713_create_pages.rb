class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.jsonb :title_i18n, default: {}
      t.string :slug, null: false
      t.jsonb :body_i18n, default: {}

      t.timestamps
    end
  end
end
