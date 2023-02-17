class ChangeClimateDealFormNameInExternalLinkManager < ActiveRecord::Migration[5.2]
  def change
    rename_column :external_link_managers, :climate_deal_form_i18n, :climate_deal_meeting_form_i18n
  end
end
