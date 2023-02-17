namespace :shares_purchases do
  desc "Associate with company if needed"
  task associate_company: :environment do
    SharesPurchase.where.not(company_info: nil).where(company_id: nil).find_each do |shares_purchase|
      individual = shares_purchase.individual
      next unless individual.shares_purchases&.where&.not(company_info: nil)&.count == 1 &&
        individual.user&.companies&.count == 1

      shares_purchase.update(company: individual.user.companies.first)
    end
  end

  def puts_stats(stats)
    puts "DONE!"
    puts ""

    puts "--- SHARES STATS ---"
    puts "Bulletin imported for #{stats[:ok].size} shares. IDs:"
    puts stats[:ok].to_json
    puts ""

    puts "Bulletin not imported for #{stats[:not_ok].size} shares. IDs:"
    puts stats[:not_ok].to_json
    puts ""
  end

  desc "Try automatically fetching BS from zoho zign for card purchase"
  task fetch_gift_bs_with_date: :environment do
    stats = {
      ok: [],
      not_ok: {}
    }

    SharesPurchase
      .without_subscription_bulletin
      .where(payment_method: :gift_coupon)
      .where(status: :pending).find_each do |purchase|

      bulletin = ZohoSign.new.unique_signed_bulletin_around(
        purchase.individual.email,
        purchase.form_completed_at - 1.day,
        purchase.form_completed_at + 7.days,
        purchase.payment_method
      )
      if bulletin.is_a?(String)
        puts "#{purchase.id}: #{bulletin}"
        stats[:not_ok][purchase.id] = bulletin
      else
        puts "#{purchase.id}: ok"
        stats[:ok] << purchase.id
        begin
          ZohoSign.new.handle_sign_webhook({requests: bulletin.deep_symbolize_keys}, purchase)
        rescue ActiveRecord::RecordInvalid => e
          puts e
          next
        end
      end
    end

    puts_stats(stats)
  end

  desc "Try automatically fetching BS from zoho zign for card purchase"
  task fetch_gift_bs: :environment do
    stats = {
      ok: [],
      not_ok: {}
    }

    SharesPurchase
      .without_subscription_bulletin
      .where(payment_method: :gift_coupon)
      .where(status: :pending).find_each do |purchase|

      bulletin = ZohoSign.new.unique_signed_bulletin(purchase.individual.email)
      if bulletin.is_a?(String)
        puts "#{purchase.id}: #{bulletin}"
        stats[:not_ok][purchase.id] = bulletin
      else
        puts "#{purchase.id}: ok"
        stats[:ok] << purchase.id
        begin
          ZohoSign.new.handle_sign_webhook({requests: bulletin.deep_symbolize_keys}, purchase)
        rescue ActiveRecord::RecordInvalid => e
          puts e
          next
        end
      end
    end

    puts_stats(stats)
  end

  desc "Try automatically fetching BS from zoho zign for completed purchases"
  task fetch_historical_bs: :environment do
    stats = {
      ok: [],
      not_ok: {}
    }

    SharesPurchase
      .left_joins(:subscription_bulletin_attachment)
      .where(subscription_bulletin_attachment: {id: nil})
      .where(status: :completed)
      .where.not(completed_at: nil)
      .find_each do |purchase|

      bulletin = ZohoSign.new.unique_signed_bulletin_around(
        purchase.individual.email,
        purchase.completed_at - 7.days,
        purchase.completed_at + 7.days,
        purchase.payment_method
      )

      if bulletin.is_a?(String)
        puts "#{purchase.id}: #{bulletin}"
        stats[:not_ok][purchase.id] = bulletin
      else
        puts "#{purchase.id}: ok"
        stats[:ok] << purchase.id
        begin
          ZohoSign.new.handle_sign_webhook({requests: bulletin}, purchase)
        rescue ActiveRecord::RecordInvalid => e
          puts e
          next
        end
      end
    end

    puts_stats(stats)
  end

  desc "Flag possible duplicates"
  task flag_duplicates: :environment do
    SharesPurchase.where.not(status: :canceled).find_each do |shares_purchase|
      DetectSharesPurchaseDuplicatesJob.perform_later(shares_purchase.id)
    end
  end
end
