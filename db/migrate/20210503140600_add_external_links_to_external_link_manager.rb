class AddExternalLinksToExternalLinkManager < ActiveRecord::Migration[5.2]
  def change
    add_column :external_link_managers, :climate_deal_presentation_document_i18n, :jsonb, default: {}
    add_column :external_link_managers, :climate_deal_simulator_form_i18n, :jsonb, default: {}
    add_column :external_link_managers, :report_video_i18n, :jsonb, default: {}
  end
end
