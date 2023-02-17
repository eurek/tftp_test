class CreateFundedInnovation < ActiveRecord::Migration[6.1]
  def change
    create_table :funded_innovations do |t|
      t.date :funded_at
      t.date :company_created_at
      t.integer :amount_invested
      t.jsonb :summary_i18n, default: {}
      t.jsonb :scientific_committee_opinion_i18n, default: {}
      t.string :video_link
      t.string :pitch_deck_link
      t.float :ghg_impact
      t.float :replicability
      t.float :potential_market
      t.float :technical_feasibility
      t.float :induced_externalities
      t.float :disruptability
      t.belongs_to :innovation
    end


    add_reference :users, :funded_innovation, foreign_key: true
  end
end
