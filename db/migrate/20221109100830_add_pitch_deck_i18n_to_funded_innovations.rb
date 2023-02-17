class AddPitchDeckI18nToFundedInnovations < ActiveRecord::Migration[6.1]
  def change
    add_column :funded_innovations, :pitch_deck_link_i18n, :jsonb, default: {}
  end
end
