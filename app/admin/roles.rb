ActiveAdmin.register Role do
  menu parent: :shareholders, priority: 6
  actions :index, :show, :edit, :update
  permit_params :name, :description

  filter :name
  filter :description

  index do
    selectable_column
    id_column
    column_without_fallback :name
    column_without_fallback :description
    column :position
    column :attributable_to
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row_without_fallback :name
      row_without_fallback :description
      row :position
      row :attributable_to
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end

    panel "Users" do
      index_table_for(resource.users) do
        id_column
        column :first_name
        column :last_name
      end
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :name, as: :translatable_string
      f.input :description, as: :translatable_text
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  controller do
    before_action :forbid_edit_french, only: [:edit]

    def forbid_edit_french
      redirect_to admin_roles_path, alert: "French version is controlled in airtable" if params[:locale] == "fr"
    end
  end
end
