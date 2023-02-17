class AddPolymorphicRelationToRoleAtttribution < ActiveRecord::Migration[6.1]
  def change
    add_reference :role_attributions, :shareholder, polymorphic: true, index: true
  end
end
