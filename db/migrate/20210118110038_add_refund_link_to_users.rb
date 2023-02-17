class AddRefundLinkToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :refund_link, :string
  end
end
