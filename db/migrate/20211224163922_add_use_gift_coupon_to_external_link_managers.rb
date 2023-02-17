class AddUseGiftCouponToExternalLinkManagers < ActiveRecord::Migration[6.1]
  def change
    add_column :external_link_managers, :use_gift_coupon_i18n, :jsonb, default: {}
  end
end
