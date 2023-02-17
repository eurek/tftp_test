class MoveTypeformLanguageFromIndividualsToSharesPurchases < ActiveRecord::Migration[6.1]
  def change
    remove_column :individuals, :typeform_language, :string
    add_column :shares_purchases, :typeform_language, :string
    add_column :individuals, :id_card_received, :boolean, null: false, default: false
  end
end
