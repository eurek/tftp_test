class RemoveReferencesBetweenUserAndMultipleModels < ActiveRecord::Migration[6.1]
  def change
    remove_reference :evaluations, :user
    remove_reference :users, :funded_innovation
    remove_reference :shares_purchases, :user
  end
end
