class FundedInnovation < ApplicationRecord
  extend Mobility

  translates :summary, :scientific_committee_opinion, :carbon_potential, :pitch_deck_link

  belongs_to :innovation
  belongs_to :funding_episode, class_name: "Episode", optional: true, foreign_key: "funding_episode_id"
  has_many :team_members, class_name: "Individual", foreign_key: :funded_innovation_id, dependent: :nullify
  has_many_attached :pictures

  validates :funded_at, :amount_invested, presence: true

  after_save :associate_to_funding_episode, if: :saved_change_to_funded_at?

  enum development_stage: {
    laboratory: "laboratory",
    prototype: "prototype",
    industrial_or_pre_industrial: "industrial_or_pre_industrial"
  }, _suffix: :stage

  private

  def associate_to_funding_episode
    funding_episode = Episode.where("started_at <= ?", funded_at).where("finished_at >= ?", funded_at).first
    update(funding_episode: funding_episode)
  end
end
