class CreateProblems < ActiveRecord::Migration[5.2]
  def change
    create_table :problems do |t|
      t.jsonb :title_i18n, null: false, default: "{}"
      t.jsonb :description_i18n, null: false, default: "{}"
      t.string :action_lever
      t.string :domain
      t.jsonb :full_content_i18n, null: false, default: "{}"
      t.integer :position

      t.timestamps
    end
  end
end
