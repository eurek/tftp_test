class RemoveRefundLinkFromUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :refund_link, :string
  end
end
