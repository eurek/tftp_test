require "rails_helper"

describe StatisticsCollecter do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  context "time dependant data" do
    before(:each) do
      stubbed_date = Date.new(2020, 3, 15)
      allow(Date).to receive(:today).and_return(stubbed_date)
      allow(Time).to receive(:now).and_return(stubbed_date.to_time)
      @beginning_of_current_month = Date.new(2020, 3, 1)

      FactoryBot.create(:shares_purchase, completed_at: Date.new(2019, 12, 1), amount: 10, status: "completed")
      3.times do
        FactoryBot.create(:shares_purchase, completed_at: Date.new(2020, 1, 1), amount: 10, status: "completed")
      end
      10.times do
        FactoryBot.create(:shares_purchase, completed_at: Date.new(2020, 2, 25), amount: 10, status: "completed")
      end
      50.times do
        FactoryBot.create(:shares_purchase, completed_at: Date.new(2020, 3, 1), amount: 10, status: "completed")
      end
    end

    describe "#all_monthly_data" do
      before(:each) do
        FactoryBot.create(
          :statistic,
          date: Date.new(2019, 12, 1),
          total_shareholders: 10,
          total_innovations_assessed: 0,
          total_innovations_assessors: 0
        )
        FactoryBot.create(
          :statistic,
          date: Date.new(2020, 1, 1),
          total_shareholders: 25,
          total_innovations_assessed: 0,
          total_innovations_assessors: 0
        )
        FactoryBot.create(
          :statistic,
          date: Date.new(2020, 2, 1),
          total_shareholders: 50,
          total_innovations_assessed: 1,
          total_innovations_assessors: 3
        )
        FactoryBot.create(
          :statistic,
          date: Date.new(2020, 3, 1),
          total_shareholders: 100,
          total_innovations_assessed: 3,
          total_innovations_assessors: 5
        )

        CurrentSituation.last.update(total_shareholders: 230)

        FactoryBot.create(:innovation, submitted_at: Date.new(2019, 12, 1))
        FactoryBot.create(:innovation, submitted_at: Date.new(2019, 12, 15))
        FactoryBot.create(:innovation, submitted_at: Date.new(2020, 1, 1))
        FactoryBot.create(:innovation, submitted_at: Date.new(2020, 2, 1))
        FactoryBot.create(:innovation, submitted_at: Date.new(2020, 3, 1))

        @home_statistics = StatisticsCollecter.new.all_monthly_data
      end

      it "doesn't show current month in datasets" do
        expect(@home_statistics[:shares_purchases][:dataset]
                 .any? { |datapoint| datapoint[:x] == @beginning_of_current_month })
          .to be false
        expect(@home_statistics[:shareholders][:dataset]
                 .any? { |datapoint| datapoint[:x] == @beginning_of_current_month })
          .to be false
        expect(@home_statistics[:innovation_assessors][:dataset]
                 .any? { |datapoint| datapoint[:x] == @beginning_of_current_month })
          .to be false
        expect(@home_statistics[:innovations_assessed][:dataset]
                 .any? { |datapoint| datapoint[:x] == @beginning_of_current_month })
          .to be false
      end

      it "collects and computes all statistics needed" do
        expected_statistics = {
          shares_purchases: {
            total: 640,
            dataset: [
              {x: StatisticsCollecter::START_DATE, y: 10},
              {x: StatisticsCollecter::START_DATE + 1.month, y: 40},
              {x: StatisticsCollecter::START_DATE + 2.month, y: 140}
            ]
          },
          shareholders: {
            total: 64,
            dataset: [
              {x: StatisticsCollecter::START_DATE, y: 10},
              {x: StatisticsCollecter::START_DATE + 1.month, y: 25},
              {x: StatisticsCollecter::START_DATE + 2.month, y: 50}
            ]
          },
          innovation_assessors: {
            total: 5,
            dataset: [
              {x: StatisticsCollecter::START_DATE, y: 0},
              {x: StatisticsCollecter::START_DATE + 1.month, y: 0},
              {x: StatisticsCollecter::START_DATE + 2.month, y: 3}
            ]
          },
          innovations_assessed: {
            total: 5,
            dataset: [
              {x: StatisticsCollecter::START_DATE, y: 2},
              {x: StatisticsCollecter::START_DATE + 1.month, y: 3},
              {x: StatisticsCollecter::START_DATE + 2.month, y: 4}
            ]
          },
          funded_innovations: {
            total: 0,
            dataset: [
              {x: StatisticsCollecter::START_DATE, y: 0},
              {x: StatisticsCollecter::START_DATE + 1.month, y: 0},
              {x: StatisticsCollecter::START_DATE + 2.month, y: 0}
            ]
          }
        }

        expect(@home_statistics).to eq(expected_statistics)
      end

      it "add zeros if needed" do
        2.times { Innovation.delete(Innovation.first.id) }

        expect(StatisticsCollecter.new.all_monthly_data[:innovations_assessed]).to eq(
          {
            total: 3,
            dataset: [
              {x: StatisticsCollecter::START_DATE, y: 0},
              {x: StatisticsCollecter::START_DATE + 1.month, y: 1},
              {x: StatisticsCollecter::START_DATE + 2.month, y: 2}
            ]
          }
        )
      end

      it "extends the dataset if needed" do
        FactoryBot.create(:funded_innovation, funded_at: Date.new(2020, 1, 1))

        expect(StatisticsCollecter.new.all_monthly_data[:funded_innovations]).to eq(
          {
            total: 1,
            dataset: [
              {x: StatisticsCollecter::START_DATE, y: 0},
              {x: StatisticsCollecter::START_DATE + 1.month, y: 1},
              {x: StatisticsCollecter::START_DATE + 2.month, y: 1}
            ]
          }
        )
      end

      it "and cache monthly data for 10 minutes" do
        allow(Rails).to receive(:cache).and_return(memory_store)
        cache.clear

        expect(cache.exist?("all_monthly_data")).to be(false)

        StatisticsCollecter.new.all_monthly_data

        expect(cache.exist?("all_monthly_data")).to be(true)

        # expires after 10 minutes
        allow(Time).to receive(:now).and_call_original
        Timecop.freeze(Time.now + 11.minutes) do
          expect(cache.exist?("all_monthly_data")).to be(false)

          StatisticsCollecter.new.all_monthly_data

          expect(cache.exist?("all_monthly_data")).to be(true)
        end
      end
    end

    describe "#shares_purchases" do
      it "returns the statistics of the shares purchased plus a goal and a beginning at 0" do
        expected_statistics = {
          historic: [
            {x: StatisticsCollecter::START_DATE - 1.month, y: 0},
            {x: StatisticsCollecter::START_DATE, y: 10},
            {x: StatisticsCollecter::START_DATE + 1.month, y: 40},
            {x: StatisticsCollecter::START_DATE + 2.month, y: 140}
          ],
          goal: [
            {x: StatisticsCollecter::START_DATE + 2.month, y: 140},
            {
              x: @beginning_of_current_month + 1.month,
              y: 1_000_140
            }
          ]
        }

        expect(StatisticsCollecter.new.shares_purchases).to eq(expected_statistics)
      end
    end

    describe "#shares_purchases_by_citizens_last_week" do
      it "returns the count of share purchases done by citizens during previous 7 days" do
        6.times do
          FactoryBot.create(:shares_purchase, completed_at: Time.now)
        end
        3.times do
          FactoryBot.create(:shares_purchase, completed_at: Time.now - 8.days)
        end
        2.times do
          FactoryBot.create(:shares_purchase, :from_company, completed_at: Time.now)
        end

        expect(StatisticsCollecter.new.shares_purchases_by_citizens_last_week).to eq 6
      end
    end

    describe "#shares_purchases_by_companies_last_week" do
      it "returns the count of share purchases done by companies during previous 7 days" do
        6.times do
          FactoryBot.create(:shares_purchase, completed_at: Time.now)
        end
        3.times do
          FactoryBot.create(:shares_purchase, completed_at: Time.now - 8.days, temporary_company_name: "Company Inc")
        end
        4.times do
          FactoryBot.create(:shares_purchase, :from_company, completed_at: Time.now)
        end

        expect(StatisticsCollecter.new.shares_purchases_by_companies_last_week).to eq 4
      end
    end
  end

  describe "#shareholders_count" do
    it "returns the number of shareholders" do
      2.times do
        FactoryBot.create(:shares_purchase, :from_company, status: "pending")
      end
      4.times do
        FactoryBot.create(:shares_purchase, :from_company, status: "completed")
      end
      3.times do
        FactoryBot.create(:shares_purchase, status: "pending")
      end
      5.times do
        FactoryBot.create(:shares_purchase, status: "completed")
      end

      expect(StatisticsCollecter.new.shareholders_count).to eq({citizen: 5, companies: 4, all: 9})
    end

    it "doesn't count two times the same shareholder" do
      individual = FactoryBot.create(:individual)
      company = FactoryBot.create(:company)
      2.times do
        FactoryBot.create(:shares_purchase, company: company, status: "completed")
      end
      4.times do
        FactoryBot.create(:shares_purchase, individual: individual, status: "completed")
      end

      expect(StatisticsCollecter.new.shareholders_count).to eq({citizen: 1, companies: 1, all: 2})
    end

    it "doesn't count twice the company and the shareholder via company" do
      individual = FactoryBot.create(:individual)
      company = FactoryBot.create(:company)
      2.times do
        FactoryBot.create(:shares_purchase, company: company, individual: individual, status: "completed")
      end

      expect(StatisticsCollecter.new.shareholders_count).to eq({citizen: 0, companies: 1, all: 1})
    end
  end

  describe "#operation_100_k" do
    it "gives to total of money raised since beginning of operation" do
      2.times do
        FactoryBot.create(
          :shares_purchase, status: "completed", completed_at: Date.parse("26-12-2022").midnight, amount: 10
        )
      end
      3.times do
        FactoryBot.create(
          :shares_purchase, status: "pending", completed_at: Date.parse("26-12-2022").midnight, amount: 10
        )
      end
      4.times do
        FactoryBot.create(
          :shares_purchase, status: "completed", completed_at: Date.parse("28-12-2022").midnight, amount: 10
        )
      end
      5.times do
        FactoryBot.create(
          :shares_purchase, status: "pending", completed_at: Date.parse("28-12-2022").midnight, amount: 10
        )
      end

      expect(StatisticsCollecter.new.operation_100_k[:total_raised]).to eq 40
    end

    it "gives the total of new shareholders" do
      already_shareholder = FactoryBot.create(:individual)

      FactoryBot.create(
        :shares_purchase,
        individual: already_shareholder,
        status: "completed",
        completed_at: Date.parse("26-12-2022").midnight
      )
      FactoryBot.create(
        :shares_purchase,
        individual: already_shareholder,
        status: "completed",
        completed_at: Date.parse("28-12-2022").midnight
      )
      FactoryBot.create(
        :shares_purchase,
        status: "pending",
        completed_at: Date.parse("28-12-2022").midnight
      )
      FactoryBot.create(
        :shares_purchase,
        status: "completed",
        completed_at: Date.parse("28-12-2022").midnight
      )

      expect(StatisticsCollecter.new.operation_100_k[:shareholders_count]).to eq 1
    end

    it "gives the number of missing shareholders to reach to goal" do
      10.times do
        FactoryBot.create(
          :shares_purchase,
          status: "completed",
          completed_at: Date.parse("26-12-2022").midnight
        )
      end

      10.times do
        FactoryBot.create(
          :shares_purchase,
          status: "completed",
          completed_at: Date.parse("28-12-2022").midnight
        )
      end

      expect(StatisticsCollecter.new.operation_100_k[:missing_shareholders]).to eq 99980
    end
  end
end
