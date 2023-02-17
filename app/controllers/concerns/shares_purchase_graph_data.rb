module SharesPurchaseGraphData
  extend ActiveSupport::Concern

  included do
    def set_shares_purchases_graph_data
      @current_situation = CurrentSituation.first
      @current_episode = Episode.current.decorate
      @shares_purchases_statistics = StatisticsCollecter.new.shares_purchases
      @total_raised = SharesPurchase.total_raised
    end
  end
end
