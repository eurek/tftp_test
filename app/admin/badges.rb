ActiveAdmin.register Badge do
  menu parent: :shareholders, priority: 5
  permit_params :name, :category, :description, :fun_description, :value

  filter :name
  filter :description
  filter :fun_description
  filter :category

  index do
    selectable_column
    id_column
    column_without_fallback :name
    column_without_fallback :description
    column_without_fallback :fun_description
    column :value
    column :position
    column :category
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row_without_fallback :name
      row_without_fallback :description
      row_without_fallback :fun_description
      row :position
      row :category
      row :value
    end

    attributes_table title: "Assets" do
      row_image :picture_light
      row_image :picture_dark
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end

    # TEST:
    panel "Users" do
      index_table_for(resource.individuals.decorate) do
        id_column
        column :full_name
      end
    end

    panel "Companies" do
      index_table_for(resource.companies) do
        id_column
        column :name
      end
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :name, as: :translatable_string
      f.input :description, as: :translatable_text
      f.input :fun_description, as: :translatable_text
      f.input :category, as: :radio, collection: Badge.categories
      f.input :value
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  # TEST: Commented for the technical test
  # controller do
  #   before_action :forbid_edit_french, only: [:edit]

  #   def forbid_edit_french
  #     redirect_to admin_badges_path, alert: "French version is controlled in airtable" if params[:locale] == "fr"
  #   end
  # end
end
