class AddStatusOnContents < ActiveRecord::Migration[5.2]
  def change
    add_column :contents, :status_i18n, :jsonb, default: {}
  end
end
