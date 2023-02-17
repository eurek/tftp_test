class Forest::Individual
  include ForestLiana::Collection

  collection :Individual

  action "Send Account Creation Email", type: "single"

  # https://docs.forestadmin.com/documentation/v/v7-v6-rails/reference-guide/fields/create-and-manage-smart-fields
  ::Individual.lockbox_attributes.each do |key, config|
    type = Forest::LOCKBOX_TYPES_CORRESPONDENCES[config[:type]]
    raise "Unknown type for attribute #{key}" if type.nil?

    set = lambda do |params, value|
      params[key] = value
      params
    end

    search = nil
    filter = nil
    if ::Individual.blind_indexes.key?(key)
      search = lambda do |query, term|
        term_bidx = Individual.send(:"generate_#{key}_bidx", term)
        query.where_clause.send(:predicates)[0] << " OR (#{key}_bidx = '#{term_bidx}')"
        query
      end

      filter = lambda do |condition, where|
        term_bidx = Individual.send(:"generate_#{key}_bidx", condition["value"])

        case condition["operator"]
        when "equal"
          "#{key}_bidx = '#{term_bidx}'"
        when "not_equal"
          "#{key}_bidx != '#{term_bidx}'"
        else
          ""
        end
      end
    end

    field key, type: type, set: set, search: search, is_filterable: filter.present?, filter: filter do
      object.send(key)
    end
  end

  field :public_profile, type: "String" do
    ForestLiana.application_url +
      Rails.application.routes.url_helpers.shareholder_individual_show_path(object, locale: :fr)
  end

  field :full_name, type: "String" do
    object.full_name
  end

  field :total_shares_amount, type: "number" do
    object.shares_purchases&.where(status: "completed")&.where(company_id: nil)&.sum(:amount)
  end

  segment "Shareholders" do
    shareholders_id = SharesPurchase.joins(:individual).where(company_id: nil).where(status: "completed")
      .pluck("individuals.id").uniq
    {id: shareholders_id}
  end

  segment "Shareholders Via an organization" do
    shareholders_id = SharesPurchase.joins(:individual).where.not(company_id: nil).where(status: "completed")
      .pluck("individuals.id").uniq
    {id: shareholders_id}
  end

  segment "Issue with address" do
    shareholders_id = SharesPurchase.joins(:individual).where(company_id: nil)
      .where(individuals: {latitude: nil})
      .pluck("individuals.id").uniq
    {id: shareholders_id}
  end
end
