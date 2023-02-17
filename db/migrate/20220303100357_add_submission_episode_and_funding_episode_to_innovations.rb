class AddSubmissionEpisodeAndFundingEpisodeToInnovations < ActiveRecord::Migration[6.1]
  def change
    add_reference :innovations, :submission_episode, foreign_key: {to_table: :episodes}
    add_reference :innovations, :funding_episode, foreign_key: {to_table: :episodes}
  end
end
