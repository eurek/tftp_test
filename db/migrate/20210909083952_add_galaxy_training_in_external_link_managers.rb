class AddGalaxyTrainingInExternalLinkManagers < ActiveRecord::Migration[5.2]
  def change
    add_column :external_link_managers, :galaxy_training_event_i18n, :jsonb, default: {}
  end
end
