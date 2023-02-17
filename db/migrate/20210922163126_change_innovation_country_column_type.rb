class ChangeInnovationCountryColumnType < ActiveRecord::Migration[6.1]
  def change
    remove_column :innovations, :country_i18n, :jsonb, default: {}
    add_column :innovations, :country, :string
  end
end
