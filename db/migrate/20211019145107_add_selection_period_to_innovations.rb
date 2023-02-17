class AddSelectionPeriodToInnovations < ActiveRecord::Migration[6.1]
  def change
    add_column :innovations, :selection_period, :string
  end
end
