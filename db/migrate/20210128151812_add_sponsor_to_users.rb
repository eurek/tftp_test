class AddSponsorToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :sponsor, foreign_key: { to_table: :users }
    add_column :users, :sponsorship_campaign_active, :boolean, default: false
    add_column :users, :sponsorship_campaign_start_date, :date
  end
end
