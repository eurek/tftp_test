module CompanyHelper
  def results_count(companies, name_params)
    if name_params.present? && companies.count > 1
      "#{companies.count} #{t("private_space.choose_company.results")}"
    elsif name_params.present? && companies.count == 1
      "1 #{t("private_space.choose_company.result")}"
    elsif name_params.present? && companies.count == 0
      t("private_space.choose_company.no_result")
    else
      ""
    end
  end

  def shareholder_status(company)
    if company.shareholder?
      "#{t("shareholder.user_show.infos.emphased")} #{I18n.l(@company.shareholder_since.to_date, format: :default)}"
    else
      t("shareholder.company_show.not_yet_shareholder")
    end
  end

  def company_card_link(company, is_employer_step, shares_purchase_id = nil)
    company_params = company.attributes.slice("id", "name", "address", "open_corporates_company_number",
      "open_corporates_jurisdiction_code", "street_address", "zip_code", "city", "country")
    if is_employer_step
      assign_employer_path({company: company_params})
    elsif shares_purchase_id.present?
      select_company_as_shareholder_path(
        company: company_params,
        shares_purchase_id: shares_purchase_id,
        search: params[:search].permit(:name, :exact)
      )
    else
      root_path
    end
  end

  def resolve_edit_company_back_link_anchor(from_companies_index_param)
    if from_companies_index_param == "true"
      t("private_space.companies_index.back_link")
    else
      t("private_space.edit_company.back_link_anchor")
    end
  end

  def resolve_edit_company_back_link_path(from_companies_index_param, shares_purchase_id = nil, previous_search = nil)
    if from_companies_index_param == "true"
      companies_path
    else
      choose_company_path(shares_purchase_id: shares_purchase_id, search: {name: previous_search})
    end
  end
end
