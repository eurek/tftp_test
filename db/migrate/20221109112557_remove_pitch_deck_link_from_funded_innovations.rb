class RemovePitchDeckLinkFromFundedInnovations < ActiveRecord::Migration[6.1]
  def change
    remove_column :funded_innovations, :pitch_deck_link, :string
  end
end
