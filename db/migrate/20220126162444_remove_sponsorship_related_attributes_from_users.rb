class RemoveSponsorshipRelatedAttributesFromUsers < ActiveRecord::Migration[6.1]
  def change
    remove_reference :users, :sponsor, index: true, foreign_key: { to_table: :users }
    remove_column :users, :sponsorship_campaign_active, :boolean
    remove_column :users, :sponsorship_campaign_start_date, :date
  end
end
