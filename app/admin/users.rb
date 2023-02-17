ActiveAdmin.register User do
  controller do
    include ActiveAdminFixResourcesPaths
  end

  menu parent: :shareholders, priority: 2

  includes :companies

  permit_params :password, :password_confirmation

  scope :all, default: true
  scope "Ambassadeur·rice" do |scope|
    scope.where.not(generated_visits: 0)
  end

  batch_action :destroy, false

  filter :id
  filter :generated_visits

  index do
    selectable_column
    id_column
    column :generated_visits
    actions
  end

  show do
    attributes_table do
      row :id
      row :generated_visits
      row :created_at
      row :updated_at
    end

    panel "Individual" do
      index_table_for(resource.individual) do
        id_column
        column :external_uid
        column :first_name
        column :last_name
        column :email
      end
    end

    panel "Companies" do
      index_table_for(resource.companies) do
        id_column
        column :name
        column :address
      end
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      if f.object.new_record?
        f.input :password
        f.input :password_confirmation
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
