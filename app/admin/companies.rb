ActiveAdmin.register Company do
  controller do
    include ActiveAdminFixResourcesPaths

    def find_resource
      scoped_collection.where(public_slug: params[:id].split("-").first).first ||
        scoped_collection.where(id: params[:id]).first!
    end
  end

  menu parent: :shareholders, priority: 3

  permit_params :name, :address, :description, :co2_emissions_reduction_actions, :linkedin, :facebook, :website,
    :is_displayed, :open_corporates_company_number, :open_corporates_jurisdiction_code, :admin_id, :logo

  includes :admin, :employees, :shares_purchases

  filter :name
  filter :co2_emissions_reduction_actions
  filter :is_displayed

  scope :all, default: true
  scope "Duplicates" do |scope|
    sql = 'SELECT lower("companies"."name") as lower_name FROM "companies" GROUP BY lower_name HAVING (count(*) > 1)'
    dup_names = ApplicationRecord.connection.select_all(sql).rows.flatten
    scope.where("name ILIKE ANY (array[?])", dup_names)
  end

  config.sort_order = "name_asc"

  batch_action :deduplicate,
    confirm: "Etes vous sûr·e? Si oui rentrez ci-dessous l'id de l'entreprise que vous souhaitez conserver ",
    form: {chosen_record_id: :text} do |ids, inputs|

    companies = Company.where(id: ids)
    chosen_company = Company.find_by(id: inputs[:chosen_record_id].to_i)

    if !ids.include?(inputs[:chosen_record_id])
      flash[:alert] = "ID faux, impossible de dédupliquer"
    elsif ids.length != 2
      flash[:alert] = "Veuillez sélectionner 2 entreprises"
    elsif companies.pluck(:name).map { |name| name.downcase }.uniq.length > 1
      flash[:alert] = "Ces entreprises ont des noms différents, impossible de les merger."
    else
      company_to_delete = (companies - [chosen_company])[0]
      Company.deduplicate(chosen_company, company_to_delete)
      flash[:notice] = "Les entreprises ont été mergées."
    end

    redirect_to collection_path(scope: :duplicates)
  end

  index do
    selectable_column
    id_column
    column :name
    column :address
    column :admin
    column :website
    column :description
    column :is_displayed
    column :employees do |resource|
      resource.employees.length # length is eager-loaded, not count
    end
    actions
  end

  show do
    attributes_table do
      row :name
      row :address
      row :description
      row :co2_emissions_reduction_actions
      row :linkedin
      row :facebook
      row :website
      row :is_displayed
      row :open_corporates_company_number
      row :open_corporates_jurisdiction_code
      row :admin
      row :employees do |resource|
        resource.employees.length # length is eager-loaded, not count
      end
    end

    attributes_table title: "Assets" do
      row_image :logo
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end

    panel "Shares purchases" do
      index_table_for(resource.shares_purchases.order(completed_at: :desc)) do
        id_column
        column :amount
        column :completed_at
      end
    end

    panel "Employees" do
      index_table_for(resource.employees) do
        id_column
        column :first_name
        column :last_name
        column :email
      end
    end

    panel "Badges" do
      index_table_for(resource.badges.order(position: :asc)) do
        id_column
        column :name
      end
    end
  end

  form do |f|
    employees_collection = object
      .employees
      .joins(:user)
      .pluck(:first_name_ciphertext, :last_name_ciphertext, "users.id").map do |employee|
      [
        "#{Individual.decrypt_first_name_ciphertext(employee[0])} "\
        "#{Individual.decrypt_last_name_ciphertext(employee[1])}",
        employee[2]
      ]
    end
    f.semantic_errors # shows errors on :base

    f.input :name
    f.input :address
    f.input :description
    f.input :logo, as: :image
    f.input :co2_emissions_reduction_actions
    f.input :linkedin
    f.input :facebook
    f.input :website
    f.input :is_displayed
    f.input :admin, as: :select, collection: employees_collection

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  collection_action :input_search, method: :get do
    # called by shares_purchases form using https://select2.org/data-sources/ajax#jquery-ajax-options
    # and https://select2.org/configuration/data-attributes
    term = params[:term] || ""
    return render json: {results: []} if term.size < 2

    query = Company.name_search(term).uniq

    # https://stackoverflow.com/a/27995494/1439489
    select_keys = [:id, :name, :address]
    results = query.pluck(*select_keys).map { |pa| {id: pa[0], text: pa[1] + " " + pa[2]} }

    render json: {results: results}
  end
end
