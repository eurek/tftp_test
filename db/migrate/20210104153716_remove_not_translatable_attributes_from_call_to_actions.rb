class RemoveNotTranslatableAttributesFromCallToActions < ActiveRecord::Migration[5.2]
  def change
    remove_column :call_to_actions, :text, :string
    remove_column :call_to_actions, :button_text, :string
    remove_column :call_to_actions, :href, :string
  end
end
