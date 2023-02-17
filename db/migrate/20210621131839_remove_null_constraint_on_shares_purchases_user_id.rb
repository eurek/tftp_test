class RemoveNullConstraintOnSharesPurchasesUserId < ActiveRecord::Migration[5.2]
  def change
    change_column :shares_purchases, :user_id, :bigint, null: true
  end
end
