class CreateStatistics < ActiveRecord::Migration[5.2]
  def change
    create_table :statistics do |t|
      t.date :date, null: false
      t.integer :total_shareholders, default: 0
      t.integer :total_innovations_assessed, default: 0
      t.integer :total_companies_funded, default: 0
    end
  end
end
