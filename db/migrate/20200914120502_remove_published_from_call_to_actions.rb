class RemovePublishedFromCallToActions < ActiveRecord::Migration[5.2]
  def change
    remove_column :call_to_actions, :published, :boolean
  end
end
