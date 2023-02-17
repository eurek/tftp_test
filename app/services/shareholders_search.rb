class ShareholdersSearch
  class Result < Array
    attr_accessor :total_pages
    attr_accessor :current_page
    attr_accessor :limit_value
    attr_accessor :total_accounts
    attr_accessor :total_shareholders
    attr_accessor :next_page
    attr_accessor :prev_page
  end

  class << self
    def search_shareholders(term: "", badge_ids: [], role_ids: [], types: [], countries: [], page: 1, limit: 20)
      # compose a list of (id, created_at, table, has_pic), sort it by created_at DESC, get only the interesting page
      has_pic_sql = "CASE WHEN blob_id IS NULL THEN 0 ELSE 1 END AS has_pic"

      individuals_query = search_individuals(term, badge_ids, role_ids, types, countries)
      individuals_count = individuals_query.count
      individuals_query = individuals_query.left_joins(:picture_attachment)
      individuals_query = individuals_query.select(:id, :created_at, "'individuals' AS table", has_pic_sql)

      companies_query = search_companies(term, badge_ids, role_ids, types, countries)
      companies_count = companies_query.count
      companies_query = companies_query.left_joins(:logo_attachment)
      companies_query = companies_query.select(:id, :created_at, "'companies' AS table", has_pic_sql)

      mixed_pagination_query = "(#{individuals_query.to_sql}) UNION (#{companies_query.to_sql})"
      mixed_pagination_query += " ORDER BY has_pic DESC, created_at DESC"
      mixed_pagination_query += " OFFSET #{(page - 1) * limit} LIMIT #{limit}"
      results = ActiveRecord::Base.connection_pool.with_connection do |connexion|
        connexion.select_all(mixed_pagination_query).to_a
      end

      # fetch all objects in a minimum of requests
      individual_ids = results.select { |r| r["table"] == "individuals" }.map { |r| r["id"] }
      individuals = Individual.where(id: individual_ids).includes(
        :roles,
        picture_attachment: :blob,
        badges: {picture_light_attachment: :blob}
      )

      company_ids = results.select { |r| r["table"] == "companies" }.map { |r| r["id"] }
      companies = Company.where(id: company_ids).includes(
        :admin,
        :roles,
        logo_attachment: :blob,
        badges: {picture_light_attachment: :blob},
      )

      # reconstitute list of results
      result = (individuals + companies)

      # booleanize avatar presence as 0 or 1 so it can be ordered DESC
      result = result.sort_by do |item|
        has_pic = (item.try(:logo) || item.try(:picture)).attached?
        has_pic_int = has_pic ? 1 : 0
        [-has_pic_int, -item.created_at.to_f]
      end
      result = Result.new(result)
      result.total_pages = ((individuals_count + companies_count) / limit.to_f).ceil
      result.current_page = page
      result.next_page = page + 1
      result.next_page = page - 1
      result.limit_value = limit
      result.total_accounts = individuals_count + companies_count
      result
    end

    private

    def search_individuals(term, badge_ids, role_ids, types, countries)
      return Individual.where(id: -1) unless types.empty? || types.include?(:individual)

      scope = Individual.to_display
      scope = scope.full_text_search(term).reorder("") unless term.blank?
      scope = scope.joins(:accomplishments).where(accomplishments: {badge_id: badge_ids}) unless badge_ids.empty?
      scope = scope.joins(:role_attributions).where(role_attributions: {role_id: role_ids}) unless role_ids.empty?
      scope = scope.where(country: countries) unless countries.empty?
      scope
    end

    def search_companies(term, badge_ids, role_ids, types, countries)
      return Company.where(id: -1) unless types.empty? || types.include?(:company)

      scope = Company.to_display
      scope = scope.name_search(term).reorder("") unless term.blank?
      scope = scope.joins(:accomplishments).where(accomplishments: {badge_id: badge_ids}) unless badge_ids.empty?
      scope = scope.joins(:role_attributions).where(role_attributions: {role_id: role_ids}) unless role_ids.empty?
      scope = scope.where(country: countries) unless countries.empty?
      scope
    end
  end
end
