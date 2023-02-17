class AddFundedAtToInnovations < ActiveRecord::Migration[6.1]
  def change
    add_column :innovations, :funded_at, :date
    remove_column :statistics, :total_companies_funded, :integer
  end
end
