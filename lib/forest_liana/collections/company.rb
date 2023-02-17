class Forest::Company
  include ForestLiana::Collection

  collection :Company

  field :total_shares_amount, type: "number" do
    object.shares_purchases&.where(status: :completed)&.sum(:amount)
  end

  segment "Shareholders" do
    shareholders_id = SharesPurchase.joins(:company).where.not(company_id: nil).where(status: "completed")
      .pluck("companies.id").uniq
    {id: shareholders_id}
  end
end
