module ShareholdersConcern
  extend ActiveSupport::Concern

  included do
    def shareholder_since
      shares_purchases.where(status: "completed").order(:completed_at).first&.completed_at || created_at
    end

    def shares_total
      shares_purchases.where(status: "completed").sum(:amount)
    end
  end
end
