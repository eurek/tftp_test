class AddSomeAttributesToSharesPurchases < ActiveRecord::Migration[6.1]
  def change
    add_column :shares_purchases, :typeform_answer_uid, :string
    add_column :shares_purchases, :admin_comments, :text
    add_column :shares_purchases, :form_completed_at, :datetime
    add_column :shares_purchases, :payment_method, :string
    add_column :shares_purchases, :status, :string
    add_column :shares_purchases, :paid_at, :date
    add_column :shares_purchases, :origin, :text
    add_column :shares_purchases, :shares_classes, :string
    add_column :shares_purchases, :transfer_reference, :string
    change_column :shares_purchases, :purchased_at, :datetime, null: true
  end
end
