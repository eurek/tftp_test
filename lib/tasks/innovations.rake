namespace :innovations do
  desc "Backfill pitch_deck_link_i18n with current pitch_deck_link"
  task backfill_pitch_deck: :environment do
    Rails.logger.level = 0

    FundedInnovation.all.each do |funded_innovation|
      funded_innovation.update(pitch_deck_link_i18n: {fr: funded_innovation.pitch_deck_link})
    end
  end
end
