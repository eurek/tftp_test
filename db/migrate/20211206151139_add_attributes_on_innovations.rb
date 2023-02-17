class AddAttributesOnInnovations < ActiveRecord::Migration[6.1]
  def change
    add_column :innovations, :displayed_on_home, :string
    add_column :innovations, :amount_invested, :integer
    add_column :innovations, :carbon_potential_i18n, :jsonb, default: {}
  end
end
