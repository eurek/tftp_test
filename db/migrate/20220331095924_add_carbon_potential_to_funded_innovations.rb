class AddCarbonPotentialToFundedInnovations < ActiveRecord::Migration[6.1]
  def change
    add_column :funded_innovations, :carbon_potential_i18n, :jsonb, default: {}
  end
end
