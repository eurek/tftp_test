ActiveAdmin.register Category do
  menu parent: :contents, priority: 2

  permit_params :slug, :name, :meta_title, :meta_description, :description, :published, :body, :published
  config.filters = false

  index do
    selectable_column
    id_column
    column_without_fallback :name
    column_without_fallback :published
    column :slug
    column_without_fallback :description
    column_without_fallback :meta_title
    column_without_fallback :meta_description
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row_without_fallback :name
      row :slug
      row_without_fallback :description
      row_without_fallback :published
    end

    attributes_table title: "SEO" do
      row_without_fallback :meta_title
      row_without_fallback :meta_description
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end

    panel "Body", class: "block html_preview" do
      para resource.body(fallback: false)&.html_safe
    end
  end

  form do |f|
    using_main_locale = I18n.locale == :fr
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :name, as: :translatable_string
      f.input :description, as: :translatable_text, input_html: {rows: 10}
      f.input :published, collection: [["Yes", true], ["No", false]], value: object.published(fallback: false)
      if f.object.new_record?
        f.input :slug
      end

      panel "SEO" do
        f.input :meta_title, as: :translatable_string
        f.input :meta_description, as: :translatable_string
      end

      panel "Body" do
        f.input :body,
          as: :redactor,
          hint: "Pour ajouter une vidéo ou un iframe, bien cliquer sur <> pour passer en html."
        unless using_main_locale
          f.input :reference,
            as: :redactor,
            input_html: {
              value: object.body_fr,
              rows: 10,
              readonly: true
            }
        end
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
