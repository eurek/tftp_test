class AddIndividualIdOnMultipleTables < ActiveRecord::Migration[6.1]
  def change
    rename_column :accomplishments, :shareholder_type, :entity_type
    rename_column :accomplishments, :shareholder_id, :entity_id
    rename_column :role_attributions, :shareholder_type, :entity_type
    rename_column :role_attributions, :shareholder_id, :entity_id
    rename_index :role_attributions, 'index_role_attributions_on_shareholder', 'index_role_attributions_on_entity'
    remove_reference :role_attributions, :user
  end
end
