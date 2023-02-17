class AddTimeAppToExternalLinkManagers < ActiveRecord::Migration[6.1]
  def change
    add_column :external_link_managers, :time_app_i18n, :jsonb, default: {}
  end
end
