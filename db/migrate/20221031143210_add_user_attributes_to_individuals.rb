class AddUserAttributesToIndividuals < ActiveRecord::Migration[6.1]
  def change
    add_column :individuals, :current_job, :string
    add_column :individuals, :is_displayed, :boolean, null: false, default: true
    add_column :individuals, :description, :text
    add_column :individuals, :reasons_to_join, :text
    add_column :individuals, :external_uid, :string
    add_column :individuals, :pending, :boolean, null: false, default: true
    add_column :individuals, :public_slug, :string
    add_column :individuals, :locale, :string, array: true, default: []
  end
end
