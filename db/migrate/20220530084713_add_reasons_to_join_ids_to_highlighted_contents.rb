class AddReasonsToJoinIdsToHighlightedContents < ActiveRecord::Migration[6.1]
  def change
    add_column :highlighted_contents, :reason_to_join_ids_i18n, :jsonb, default: {}
  end
end
