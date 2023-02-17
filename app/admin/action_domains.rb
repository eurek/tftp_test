ActiveAdmin.register ActionDomain do
  menu parent: :innovations, priority: 3
  actions :index, :show, :edit, :update
  permit_params :name, :icon

  filter :name
  filter :title

  index do
    selectable_column
    id_column
    column :title
    column :name
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :title
      row_without_fallback :name
    end

    attributes_table title: "Assets" do
      row_image :icon
    end

    attributes_table title: "Metadata" do
      row :id
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base
    f.inputs do
      f.input :name, as: :translatable_string
      f.input :icon, as: :image
    end
    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
