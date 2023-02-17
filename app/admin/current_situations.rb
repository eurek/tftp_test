ActiveAdmin.register CurrentSituation do
  menu parent: :roadmap, priority: 2

  config.filters = false
  actions :all, except: [:new, :destroy]
  permit_params :locale, :description, :structure

  index do
    column :total_shareholders
    column_without_fallback :description
    column_without_fallback :structure
    actions
  end

  show do
    attributes_table do
      row :total_shareholders
      row_without_fallback :description
      row_without_fallback :structure
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :description, as: :translatable_text, input_html: {rows: 3}
      f.input :structure, as: :translatable_text, input_html: {rows: 3}
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
