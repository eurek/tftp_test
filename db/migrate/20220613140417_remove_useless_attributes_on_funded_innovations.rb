class RemoveUselessAttributesOnFundedInnovations < ActiveRecord::Migration[6.1]
  def change
    remove_column :funded_innovations, :ghg_impact, :float
    remove_column :funded_innovations, :technical_feasibility, :float
    remove_column :funded_innovations, :replicability, :float
    remove_column :funded_innovations, :induced_externalities, :float
    remove_column :funded_innovations, :potential_market, :float
    remove_column :funded_innovations, :disruptability, :float
  end
end
