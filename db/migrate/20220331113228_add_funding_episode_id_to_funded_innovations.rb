class AddFundingEpisodeIdToFundedInnovations < ActiveRecord::Migration[6.1]
  def change
    add_reference :funded_innovations, :funding_episode, foreign_key: {to_table: :episodes}
  end
end
