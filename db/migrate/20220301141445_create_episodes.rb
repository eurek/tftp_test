class CreateEpisodes < ActiveRecord::Migration[6.1]
  def change
    create_table :episodes do |t|
      t.integer :number, required: true
      t.integer :season_number, required: true
      t.string :external_uid, required: true, unique: true
      t.date :started_at
      t.date :finished_at
      t.integer :fundraising_goal
      t.jsonb :title_i18n, default: {}
      t.jsonb :description_i18n, default: {}
      t.jsonb :body_i18n, default: {}

      t.timestamps
    end
  end
end
