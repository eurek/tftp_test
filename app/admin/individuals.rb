ActiveAdmin.register Individual do
  controller do
    include ActiveAdminFixResourcesPaths

    def find_resource
      scoped_collection.where(public_slug: params[:id].split("-").first).first ||
        scoped_collection.where(id: params[:id]).first!
    end

    def index
      @highlighted_user_ids = HighlightedContent.first.reason_to_join_ids
      super
    end
  end

  actions :all, except: [:destroy]

  menu parent: :shareholders, priority: 1
  includes :badges, :roles, :shares_purchases, :picture_attachment
  permit_params :first_name, :last_name, :linkedin, :date_of_birth, :employer_id, :city, :country, :current_job,
    :is_displayed, :description, :reasons_to_join, :picture, :external_uid, :email, :phone, :address, :zip_code

  scope :all, default: true
  scope "Reasons to Join" do |scope|
    is_selected_sql = "CASE WHEN id IN (#{HighlightedContent.first.reason_to_join_ids.join(", ")}) THEN 1 ELSE 0 END "\
      "AS is_selected"
    Individual.where.not(reasons_to_join: nil)
      .where.not(reasons_to_join: "")
      .where(is_displayed: true)
      .where("locale @> ARRAY[?]::varchar[]", I18n.locale)
      .select("*", is_selected_sql)
      .order("is_selected DESC")

  end

  batch_action :destroy, false
  batch_action :highlight_reasons_to_join do |ids|
    HighlightedContent.first.update(reason_to_join_ids: (HighlightedContent.first.reason_to_join_ids || []) + ids)
    redirect_to collection_path,
      notice: "The individuals have been added to the ones displayed on become shareholder page."
  end
  batch_action :mask_reasons_to_join do |ids|
    HighlightedContent.first.update(reason_to_join_ids: (HighlightedContent.first.reason_to_join_ids || []) - ids)
    redirect_to collection_path,
      notice: "The individuals have been deleted from the ones displayed on become shareholder page."
  end

  filter :id
  filter :external_uid
  filter :email_eq, label: I18n.t("activerecord.attributes.individual.email")
  filter :first_name_eq, label: I18n.t("activerecord.attributes.individual.first_name")
  filter :last_name_eq, label: I18n.t("activerecord.attributes.individual.last_name")
  filter :date_of_birth_eq, as: :date_picker, label: I18n.t("activerecord.attributes.individual.date_of_birth")
  filter :country
  filter :is_displayed

  index do
    id_column
    column :email
    column :first_name
    column :last_name
    if params[:scope] == "reasons_to_join"
      column :reasons_to_join
      thumbnail_column :picture
      column :displayed_on_become_shareholder do |resource|
        highlighted_user_ids&.include?(resource.id.to_s)
      end
    else
      column :current_job
      column :is_displayed
      column :date_of_birth
      column :employer
      column :city
      column :country do |resource|
        resource.decorate.country_name
      end
    end
    actions
  end

  show do
    attributes_table title: "Identification" do
      row :id
      row :external_uid
      row :first_name
      row :last_name
      row :email
      row :date_of_birth
      row_image :picture
    end

    attributes_table do
      row :current_job
      row :linkedin
      row :is_displayed
      row :employer
      row :phone
      row :address
      row :zip_code
      row :city
      row :country do |resource|
        resource.decorate.country_name
      end
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end

    if resource.user.present?
      panel "User" do
        index_table_for(resource.user) do
          id_column
          column :generated_visits
          column :pending
        end
      end
    end

    panel "Shares purchases" do
      index_table_for(resource.shares_purchases.order(completed_at: :desc)) do
        id_column
        column :amount
        column :completed_at
        column :external_uid
      end
    end

    panel "Badges" do
      index_table_for(resource.badges.order(position: :asc)) do
        id_column
        column :name
      end
    end

    panel "Roles" do
      index_table_for(resource.roles) do
        id_column
        column :name
      end
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :first_name
      f.input :last_name
      f.input :external_uid
      f.input :email
      f.input :picture, as: :image
      f.input :current_job
      f.input :is_displayed
      f.input :linkedin
      f.input :date_of_birth, as: :date_picker
      f.input :employer
      f.input :phone
      f.input :address
      f.input :zip_code
      f.input :city
      f.input :country,
        as: :country,
        include_blank: true,
        selected: ISO3166::Country.find_country_by_alpha3(f.object&.country)&.alpha2
      f.input :description
      f.input :reasons_to_join
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  collection_action :input_search, method: :get do
    # called by shares_purchases form using https://select2.org/data-sources/ajax#jquery-ajax-options
    # and https://select2.org/configuration/data-attributes
    term = params[:term] || ""
    return render json: {results: []} if term.size < 2

    query = Individual.full_text_search(term).uniq

    # https://stackoverflow.com/a/27995494/1439489
    select_keys = [:id, :first_name, :last_name]
    results = query.pluck(*select_keys).map { |pa| {id: pa[0], text: pa[1] + " " + pa[2]} }

    render json: {results: results}
  end
end
