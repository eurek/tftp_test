class ChangeAssociatesUpdatesToCurrentSituations < ActiveRecord::Migration[5.2]
  def change
    rename_table :associates_updates, :current_situations
    add_column :current_situations, :description_i18n, :jsonb, default: {}
    add_column :current_situations, :structure_i18n, :jsonb, default: {}
    add_column :current_situations, :enterprises_created, :integer
  end
end
