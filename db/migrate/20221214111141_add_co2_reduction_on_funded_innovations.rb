class AddCo2ReductionOnFundedInnovations < ActiveRecord::Migration[6.1]
  def change
    add_column :funded_innovations, :co2_reduction, :jsonb
  end
end
