class AddCreatorToCompanies < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :creator_id, :integer, index: true
    add_foreign_key :companies, :users, column: :creator_id
  end
end
