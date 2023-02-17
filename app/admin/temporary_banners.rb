ActiveAdmin.register TemporaryBanner do
  menu parent: :static_pages, priority: 4

  permit_params :headline, :cta, :link, :is_displayed
  config.filters = false

  index do
    id_column
    column_without_fallback :headline
    column_without_fallback :cta
    column_without_fallback :link
    column_without_fallback :is_displayed
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row_without_fallback :headline
      row_without_fallback :cta
      row_without_fallback :link
      row_without_fallback :is_displayed
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :is_displayed, collection: [["Yes", true], ["No", false]], value: object.is_displayed(fallback: false)

      f.input :headline, as: :translatable_string
      f.input :cta, as: :translatable_string
      f.input :link, as: :translatable_string
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
