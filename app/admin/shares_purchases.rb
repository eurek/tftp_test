ActiveAdmin.register SharesPurchase do
  menu parent: :shareholders, priority: 4

  permit_params :locale, :company_id, :individual_id, :status, :subscription_bulletin,
    :subscription_bulletin_certificate

  actions :all, except: [:new, :create]

  includes subscription_bulletin_attachment: :blob

  filter :amount
  filter :completed_at
  filter :external_uid

  scope :all, default: true
  scope "By companies, not associated" do |scope|
    scope.where.not(company_info: nil).where(company_id: nil)
  end
  scope "By companies, associated" do |scope|
    scope.where.not(company_id: nil)
  end

  index do
    selectable_column
    id_column
    column :external_uid
    column :amount
    column :completed_at
    column :individual
    column :company
    column :company_info
    column :bulletin_uploaded do |resource|
      resource.subscription_bulletin.attached?
    end
    actions
  end

  show do
    attributes_table title: "Identification" do
      row :id
      row :external_uid
    end

    attributes_table do
      row :amount
      row :status
      row :completed_at
      row :individual
      row :company
      row :company_info
      row :subscription_bulletin do |resource|
        if resource.subscription_bulletin.attached?
          link_to(
            "Subscription Bulletin",
            url_for(resource.subscription_bulletin),
            target: "_blank"
          )
        end
      end
      row :subscription_bulletin_certificate do |resource|
        if resource.subscription_bulletin_certificate.attached?
          link_to(
            "Subscription Bulletin Certificate",
            url_for(resource.subscription_bulletin_certificate),
            target: "_blank"
          )
        end
      end
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :status, as: :select, collection: SharesPurchase.statuses.keys
      f.input :subscription_bulletin, as: :file
      f.input :subscription_bulletin_certificate, as: :file
      f.input :individual,
        as: :select,
        collection: Individual.where(id: f.object.individual_id),
        input_html: {'data-ajax--url': input_search_admin_individuals_path}

      f.input :company,
        as: :select,
        collection: Company.where(id: f.object.company_id),
        input_html: {'data-ajax--url': input_search_admin_companies_path}
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
