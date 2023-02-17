class RemoveObsoleteAttributesOnUser < ActiveRecord::Migration[6.1]
  def change
    remove_column :users, :current_job, :string
    remove_column :users, :is_displayed, :boolean, null: false, default: true
    remove_column :users, :description, :text
    remove_column :users, :reasons_to_join, :text
    remove_column :users, :external_uid, :string
    remove_column :users, :public_slug, :string
    remove_column :users, :locale, :string, array: true, default: []

    remove_column :individuals, :pending, :boolean, null: false, default: true
  end
end
