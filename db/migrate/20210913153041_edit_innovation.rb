class EditInnovation < ActiveRecord::Migration[5.2]
  def change
    remove_column :innovations, :name_i18n, :jsonb
    add_column :innovations, :name, :string
  end
end
