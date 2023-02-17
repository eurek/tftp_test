class CreateCompanies < ActiveRecord::Migration[5.2]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.text :address
      t.text :description
      t.text :co2_emissions_reduction_actions
      t.string :linkedin
      t.string :facebook
      t.string :website
      t.boolean :is_displayed, default: false
      t.integer :open_corporate_company_number
      t.string :open_corporate_juridiction_number
      t.references :admin, references: :users, foreign_key: {to_table: :users}, null: true

      t.timestamps
    end
  end
end
