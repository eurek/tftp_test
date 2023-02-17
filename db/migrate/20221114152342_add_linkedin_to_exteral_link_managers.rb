class AddLinkedinToExteralLinkManagers < ActiveRecord::Migration[6.1]
  def change
    add_column :external_link_managers, :linkedin_i18n, :jsonb, default: {}
  end
end
