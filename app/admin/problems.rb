ActiveAdmin.register Problem do
  controller do
    include ActiveAdminFixResourcesPaths
  end

  menu priority: 9

  before_action :skip_sidebar!, only: :index
  permit_params :cover_image, :title, :description, :action_lever, :domain, :full_content, :position

  index do
    selectable_column
    id_column
    column_without_fallback :title
    column_without_fallback :description
    column :action_lever
    column :domain
    column_without_fallback :full_content
    column :position
    actions
  end

  show do
    attributes_table do
      row_image :cover_image
      row_without_fallback :title
      row_without_fallback :description
      row :action_lever
      row :domain
      row :position
    end

    panel "Full content", class: "block html_preview" do
      para resource.full_content(fallback: false)&.html_safe
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :title, as: :translatable_string
      f.input :description, as: :translatable_text, input_html: {rows: 10}
      f.input :action_lever, as: :select, collection: Problem.action_levers.keys
      f.input :domain, as: :select, collection: Problem.domains.keys
      unless f.object.new_record?
        f.input :cover_image, as: :image
        f.input :full_content, as: :redactor
      end
      f.input :position, as: :string, hint: f.object.position
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
