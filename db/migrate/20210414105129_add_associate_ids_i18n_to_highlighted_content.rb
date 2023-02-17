class AddAssociateIdsI18nToHighlightedContent < ActiveRecord::Migration[5.2]
  def change
    add_column :highlighted_contents, :associate_ids_i18n, :jsonb, default: {}
  end
end
