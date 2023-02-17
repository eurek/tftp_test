ActiveAdmin.register Content do
  menu parent: :contents, priority: 1

  permit_params :locale, :title, :short_title, :cover_image_alt, :weight, :slug, :meta_title,
    :meta_description, :body, :cover_image, :call_to_action_id, :status,
    :youtube_video_id, :category_id, tag_ids: []

  includes :category, :tags

  filter :id
  filter :title
  filter :body
  filter :slug
  filter :category
  filter :call_to_action
  filter :weight
  filter :created_at
  filter :updated_at

  scope :all, default: true

  scope "Without tags" do |scope|
    scope.left_outer_joins(:tags).where(tags: {id: nil})
  end

  index do
    selectable_column
    id_column
    column_without_fallback :title
    column_without_fallback :status
    column :category
    column :weight
    column :slug
    column :created_at
    column :updated_at
    column_without_fallback :meta_title
    column_without_fallback :meta_description
    actions
  end

  show do
    attributes_table do
      row_without_fallback :status
      row :slug
      row_without_fallback :title
      row_without_fallback :short_title
      row_image :cover_image
      row :weight
      row :call_to_action do |content|
        content.call_to_action&.text
      end
    end

    attributes_table title: "Taxonomy" do
      row :category
      row :tags
    end

    panel "Body", class: "block html_preview" do
      para resource.body(fallback: false)&.html_safe
    end

    attributes_table title: "SEO" do
      row_without_fallback :cover_image_alt
      row_without_fallback :meta_title
      row_without_fallback :meta_description
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form html: {data: {controller: "content-tags"}} do |f|
    using_main_locale = I18n.locale == :fr

    f.actions
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :title, as: :translatable_string
      f.input :short_title, as: :translatable_string
      f.input :youtube_video_id, hint: "Mettre seulement le code, par ex: H9tIz7EYolM"
      if f.object.new_record?
        f.input :slug, as: :string
      end
      if using_main_locale
        f.input :call_to_action
      end

      unless f.object.new_record?
        if using_main_locale
          f.input :cover_image, as: :image
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

      panel "Configuration" do
        f.input :status, collection: Content::AUTHORIZED_STATUSES
        f.input :weight
      end

      if using_main_locale
        categories_collection = Category.all.sort_by { |category| category.name&.parameterize }

        tags_collection = Tag.includes(:category)
          .map { |tag| [[tag.category.name, tag.name].join(" > "), tag.id] }
          .sort_by { |values| values.first&.parameterize }

        panel "Taxonomy" do
          f.input :category, collection: categories_collection
          f.input :tags, collection: tags_collection
        end
      end

      panel "SEO" do
        f.input :cover_image_alt, as: :translatable_string
        f.input :meta_title, as: :translatable_string
        f.input :meta_description, as: :translatable_string
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  collection_action :tags_suggestions do
    category_id = params[:category_id] || []

    tags = Tag.where(category_id: category_id)
    json = tags.map { |tag| {id: tag.id, name: tag.name} }
    render json: json, status: :ok
  end
end
