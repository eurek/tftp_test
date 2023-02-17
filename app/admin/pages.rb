ActiveAdmin.register Page do
  menu parent: :static_pages, priority: 1

  permit_params :title, :slug, :body
  actions :all, except: [:new, :destroy]

  filter :title
  filter :slug
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column_without_fallback :title
    column :slug
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row_without_fallback :title
      row :slug
    end

    panel "Body", class: "block html_preview" do
      para resource.body(fallback: false)&.html_safe
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    using_main_locale = I18n.locale == :fr

    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :title, as: :translatable_string
      f.input :slug, input_html: {disabled: !object.new_record?}
      f.input :body, as: :redactor
      unless using_main_locale
        f.input :reference,
          as: :redactor,
          input_html: {
            value: object.body_fr,
            max_height: "20em",
            readonly: true
          }
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
