class CreateInnovations < ActiveRecord::Migration[5.2]
  def change
    create_table :action_levers do |t|
      t.string :title, null: false
      t.jsonb :name_i18n, default: {}

      t.timestamps
    end

    create_table :action_domains do |t|
      t.string :title, null: false
      t.jsonb :name_i18n, default: {}

      t.timestamps
    end

    create_table :founders do |t|
      t.string :full_name, null: false
      t.date :born_at

      t.timestamps
    end

    create_table :innovations do |t|
      t.jsonb :name_i18n, default: {}, null: false
      t.jsonb :short_description_i18n, default: {}
      t.jsonb :long_description_i18n, default: {}
      t.string :status, default: "assessed"
      t.date :submitted_at
      t.integer :evaluations_amount
      t.string :city
      t.jsonb :country_i18n, default: {}
      t.integer :rating
      t.references :action_lever, foreign_key: true
      t.references :action_domain, foreign_key: true

      t.timestamps
    end

    create_table :innovation_inventions do |t|
      t.references :founder, foreign_key: true
      t.references :innovation, foreign_key: true

      t.timestamps
    end
  end
end
