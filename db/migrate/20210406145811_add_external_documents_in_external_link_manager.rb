class AddExternalDocumentsInExternalLinkManager < ActiveRecord::Migration[5.2]
  def change
    add_column :external_link_managers,
      :summary_information_document_i18n,
      :jsonb,
      default: {}
  end
end
