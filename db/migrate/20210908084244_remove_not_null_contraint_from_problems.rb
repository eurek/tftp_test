class RemoveNotNullContraintFromProblems < ActiveRecord::Migration[6.0]
  def change
    change_column :problems, :title_i18n, :jsonb, null: true
    change_column :problems, :description_i18n, :jsonb, null: true
    change_column :problems, :full_content_i18n, :jsonb, null: true
  end
end
