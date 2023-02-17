class BadgesAssignmentForCategory
  attr_reader :category, :shares_purchase, :type

  INDIVIDUAL_TYPE = "Individual"
  COMPANY_TYPE = "Company"

  def initialize(category, shares_purchase, type = INDIVIDUAL_TYPE | COMPANY_TYPE)
    @category = category
    @shares_purchase = shares_purchase
    @type = type
  end

  def call
    badge_ids_to_assign = if category === Badge.categories[:financial]
      get_financial_badge_ids_to_assign
    else
      # do something for other categories because it is string value
    end

    create_accomplisments(badge_ids_to_assign) unless badge_ids_to_assign.blank?
  end

  private

  def available_financial_badges
    Badge.where(category: category).where("value::integer <= ?", shares_purchase_sum)
  end

  def create_accomplisments(badge_ids)
    accomplishments = badge_ids.map do |badge_id|
      {
        badge_id: badge_id,
        created_at: now,
        entity_type: type == INDIVIDUAL_TYPE ? INDIVIDUAL_TYPE : COMPANY_TYPE,
        entity_id: type == INDIVIDUAL_TYPE ? shares_purchase.individual_id : shares_purchase.company_id,
        updated_at: now
      }
    end

    Accomplishment.insert_all(accomplishments)
  end

  def get_financial_badge_ids_to_assign
    available_financial_badges.pluck(:id) - badge_ids_for_category_from_accomplishments
  end

  def badge_ids_for_category_from_accomplishments
    accomplishment_query = Accomplishment.joins(:badge)
      .where(badge: {category: category})

    query = if type === INDIVIDUAL_TYPE
      accomplishment_query.where(
        entity_type: INDIVIDUAL_TYPE,
        entity_id: shares_purchase.individual_id
      )
    else
      accomplishment_query.where(
        entity_type: COMPANY_TYPE,
        entity_id: shares_purchase.company_id
      )
    end

    query.pluck(:badge_id)
  end

  def now
    @now ||= DateTime.now
  end

  def shares_purchase_sum
    completed_purchase_query = SharesPurchase.where(
      individual_id: shares_purchase.individual_id,
      status: :completed,
    )

    query = if type === INDIVIDUAL_TYPE
      completed_purchase_query.where(
        company_id: nil,
      )
    else
      completed_purchase_query.where.not(company_id: nil)
    end

    query.sum(&:amount)
  end
end
