ActiveAdmin.register HighlightedContent do
  controller do
    include ActiveAdminFixResourcesPaths
  end

  menu parent: :highlights, priority: 1

  actions :all, except: [:new, :destroy]
  permit_params :published, :blog_content_id, :time_media_content_id, associate_ids: []

  config.filters = false

  index do
    selectable_column
    id_column
    column :published
    column :associates do |resource|
      User.where(id: resource.associate_ids(fallback: false))
    end
    column_without_fallback :blog_content_id
    column_without_fallback :time_media_content_id
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :published
      row_without_fallback :blog_content_id
      row_without_fallback :time_media_content_id
    end

    panel "Associates" do
      index_table_for(User.where(id: resource.associate_ids(fallback: false))) do
        id_column
        column :first_name
        column :last_name
      end
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :published
      f.input :blog_content_id,
        as: :select,
        collection: Content.joins(:category).where("categories.title": Category::BLOG_TITLE)
      f.input :time_media_content_id,
        as: :select,
        collection: Content.joins(:category).where("categories.title": Category::MEDIA_TITLE)

      # Did not find a way to pass selected values to active_admin__addon tags input
      f.li id: "highlighted_content_associate_ids_input", class: "select input optional" do
        f.label "Associates", class: "label"
        f.select :associate_ids,
          options_from_collection_for_select(
            User.all,
            "id",
            "full_name",
            f.object.associate_ids(fallback: false)
          ),
          {},
          {multiple: true, size: 10}
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
