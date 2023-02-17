class StatisticsCollecter
  # TODO: Il va probalement falloir reprendre ce fichier pour prendre en compte les status des achats de parts
  START_DATE = Date.new(2019, 12, 1).freeze

  def all_monthly_data
    Rails.cache.fetch("all_monthly_data", expires_in: 10.minutes) do
      innovations = Innovation.all
      funded_innovations = FundedInnovation.all

      {
        shares_purchases: {
          total: SharesPurchase&.total_raised,
          dataset: total_by_month(SharesPurchase.all, :completed_at, :amount)
        },
        shareholders: {
          total: shareholders_count[:all],
          dataset: generate_dataset(Statistic.pluck(:date, :total_shareholders))
        },
        innovation_assessors: {
          total: Statistic.last&.total_innovations_assessors,
          dataset: generate_dataset(Statistic.pluck(:date, :total_innovations_assessors))
        },
        innovations_assessed: {
          total: innovations.length,
          dataset: total_by_month(innovations.select(:id), :submitted_at)
        },
        funded_innovations: {
          total: funded_innovations.length,
          dataset: total_by_month(funded_innovations.select(:id), :funded_at)
        }
      }
    end
  end

  def live
    last_week = Time.now - 1.week
    last_month = Time.now - 1.month
    {
      today: periodic_statistics(Time.now.beginning_of_day, Date.yesterday.beginning_of_day, Time.now - 1.day),
      week: periodic_statistics(Time.now.beginning_of_week, last_week.beginning_of_week, last_week),
      month: periodic_statistics(Time.now.beginning_of_month, last_month.beginning_of_month, last_month)
    }
  end

  def periodic_statistics(current_period_start, last_period_start, last_period_end)
    now = Time.now
    current_purchases = SharesPurchase.select_objects_between(:completed_at, current_period_start, now)
    last_purchases = SharesPurchase.select_objects_between(:completed_at, last_period_start, last_period_end)
    current_new_shareholders = User.select_objects_between(:created_at, current_period_start, now)
    last_new_shareholders = User.select_objects_between(:created_at, last_period_start, last_period_end)
    {
      raised: current_purchases.total_raised,
      new_shareholders: current_new_shareholders.size,
      raised_variation: variation(current_purchases.total_raised, last_purchases.total_raised),
      new_shareholders_variation: variation(current_new_shareholders.size, last_new_shareholders.size)
    }
  end

  def shares_purchases
    dataset = total_by_month(SharesPurchase.all, :completed_at, :amount)
    dataset.unshift({x: START_DATE - 1.month, y: 0}).compact!
    {
      historic: dataset,
      goal: [
        dataset[-1],
        {
          x: Date.today.next_month.at_beginning_of_month,
          y: dataset[-1][:y] + 1_000_000
        }
      ]
    }
    # we arbitrary add one million to position the goal in the graph
  end

  def shares_purchases_by_citizens_last_week
    SharesPurchase.by_individual
      .select_objects_between(:completed_at, Time.now - 1.week, Time.now).count
  end

  def shares_purchases_by_companies_last_week
    SharesPurchase.by_company
      .select_objects_between(:completed_at, Time.now - 1.week, Time.now).count
  end

  def shareholders_count
    Rails.cache.fetch("shareholders_count", expires_in: 3.minutes) do
      citizen_total = SharesPurchase.where(status: "completed").where(company_id: nil).joins(:individual)
        .pluck(:individual_id).uniq.count
      company_total = SharesPurchase.where(status: "completed").where.not(company_id: nil).joins(:company)
        .pluck(:company_id).uniq.count
      {
        citizen: citizen_total,
        companies: company_total,
        all: citizen_total + company_total
      }
    end
  end

  def operation_100_k
    Rails.cache.fetch("statistics_100_k", expires_in: 10.minutes) do
      shares_purchases = SharesPurchase.where("completed_at >= ?", CurrentSituation::OPERATION_100_K_START_TIME)
        .where(status: "completed").pluck(:amount).sum
      {
        total_raised: shares_purchases,
        shareholders_count: Individual.shareholders_since(CurrentSituation::OPERATION_100_K_START_TIME).length,
        missing_shareholders: CurrentSituation::OPERATION_100_K_GOAL - shareholders_count[:all]
      }
    end
  end

  private

  def variation(current_value, base_value)
    return nil if base_value == 0

    ((current_value - base_value).to_f / base_value * 100).round
  end

  def total_by_month(collection, grouping_attribute, counting_attribute = nil)
    total = 0
    collection = collection.group_by_month(grouping_attribute, range: START_DATE..Date.today)
    collection = counting_attribute.nil? ? collection.count : collection.sum(counting_attribute)
    total_by_month = collection.map do |month, amount|
      next if month == Date.today.at_beginning_of_month

      total += amount
      {x: month, y: total}
    end
    total_by_month.compact.sort_by { |data| data[:x] }
  end

  def generate_dataset(statistics)
    statistics.map do |statistic|
      next if statistic[0] == Date.today.at_beginning_of_month

      {
        x: statistic[0],
        y: statistic[1]
      }
    end
      .compact
  end
end
