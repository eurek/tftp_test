class CreateExternalLinkManagers < ActiveRecord::Migration[5.2]
  def change
    create_table :external_link_managers do |t|
      t.jsonb :shares_purchase_form_i18n, default: {}
      t.jsonb :offer_shares_form_i18n, default: {}
      t.jsonb :company_offer_shares_form_i18n, default: {}
      t.jsonb :contact_form_i18n, default: {}
      t.jsonb :b2b_contact_form_i18n, default: {}
      t.jsonb :climate_deal_form_i18n, default: {}
      t.jsonb :innovation_proposal_form_i18n, default: {}
    end
  end
end
