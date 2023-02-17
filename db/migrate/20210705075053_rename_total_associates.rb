class RenameTotalAssociates < ActiveRecord::Migration[5.2]
  def change
    rename_column :current_situations, :total_associates, :total_shareholders
  end
end
