ActiveAdmin.register CallToAction do
  menu parent: :contents, priority: 4

  permit_params :text, :button_text, :href

  def display_name
    text
  end

  index do
    selectable_column
    id_column
    column_without_fallback :text
    column_without_fallback :button_text
    column_without_fallback :href
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row_without_fallback :text
      row_without_fallback :button_text
      row_without_fallback :href
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :text, as: :translatable_string
      f.input :button_text, as: :translatable_string
      f.input :href, as: :translatable_string
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
