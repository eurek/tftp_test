class AddCompanySharesPurchaseFormInExternalLinkManager < ActiveRecord::Migration[6.1]
  def change
    add_column :external_link_managers, :company_shares_purchase_form_i18n, :jsonb, default: {}
  end
end
