class AddTotalInnovationsAssessorsToStatistics < ActiveRecord::Migration[5.2]
  def change
    add_column :statistics, :total_innovations_assessors, :integer, default: 0
  end
end
