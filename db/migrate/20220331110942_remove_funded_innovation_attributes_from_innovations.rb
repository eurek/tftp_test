class RemoveFundedInnovationAttributesFromInnovations < ActiveRecord::Migration[6.1]
  def change
    remove_column :innovations, :amount_invested, :integer
    remove_column :innovations, :funded_at, :date
    remove_column :innovations, :carbon_potential_i18n, :jsonb, default: {}
    remove_reference :innovations, :funding_episode, foreign_key: {to_table: :episodes}
  end
end
