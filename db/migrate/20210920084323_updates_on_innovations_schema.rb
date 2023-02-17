class UpdatesOnInnovationsSchema < ActiveRecord::Migration[6.1]
  def change
    add_column :innovations, :external_uid, :string
    add_column :innovations, :language, :string
    add_column :innovations, :website, :string
    remove_column :innovations, :long_description_i18n, :jsonb
    add_column :innovations, :problem_solved_i18n, :jsonb, default: {}
    add_column :innovations, :solution_explained_i18n, :jsonb, default: {}
    add_column :innovations, :potential_clients_i18n, :jsonb, default: {}
    add_column :innovations, :differentiating_elements_i18n, :jsonb, default: {}

    remove_column :founders, :born_at, :date
  end
end
