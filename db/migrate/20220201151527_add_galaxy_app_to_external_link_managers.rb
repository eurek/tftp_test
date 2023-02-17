class AddGalaxyAppToExternalLinkManagers < ActiveRecord::Migration[6.1]
  def change
    add_column :external_link_managers, :galaxy_app_i18n, :jsonb, default: {}
  end
end
