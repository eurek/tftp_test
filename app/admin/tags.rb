ActiveAdmin.register Tag do
  menu parent: :contents, priority: 3

  permit_params :slug, :name, :category_id, :published

  filter :name
  filter :slug
  filter :published
  filter :category

  config.sort_order = "category_id_asc"

  index do
    selectable_column
    id_column
    column_without_fallback :name
    column :slug
    column :category
    column_without_fallback :published
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :category
      row_without_fallback :name
      row_without_fallback :published
      row :slug
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :name, as: :translatable_string
      f.input :published, collection: [["Yes", true], ["No", false]], value: object.published(fallback: false)
      f.input :category
      if f.object.new_record?
        f.input :slug
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
