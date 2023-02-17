class AddGiftCouponRelatedAttributesToSharesPurchases < ActiveRecord::Migration[6.1]
  def change
    add_column :shares_purchases, :gift_coupon_buyer_typeform_answer_uid, :string
    add_column :shares_purchases, :gift_coupon_amount, :integer
  end
end
