class CreateSharesPurchases < ActiveRecord::Migration[5.2]
  def change
    create_table :shares_purchases do |t|
      t.integer :amount, null: false
      t.date :purchase_date, null: false
      t.references :user, index: true, null: false
      t.references :company, index: true, null: true
      t.string :temporary_company_name
      t.timestamps
    end
  end
end
