ActiveAdmin.register Episode do
  menu priority: 3

  actions :all

  permit_params :title, :description, :body, :cover_image, :number, :season_number, :started_at,
    :finished_at, :fundraising_goal

  scope("All", default: true) { |scope| scope.ordered_by_season }

  filter :season_number

  index do
    column :id
    column :season_number
    column :number
    column :started_at
    column :finished_at
    column :fundraising_goal
    column_without_fallback :title
    actions
  end

  show do
    attributes_table do
      row :season_number
      row :number
      row :started_at
      row :finished_at
      row :fundraising_goal
      row_image :cover_image
      row_without_fallback :title
      row_without_fallback :description
      row_without_fallback :body
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
      panel "Main info" do
        f.input :number
        f.input :season_number
        f.input :started_at
        f.input :finished_at
        f.input :fundraising_goal
      end

      panel "Picture" do
        f.input :cover_image, as: :image
      end

      panel "Title and short description" do
        f.input :title, as: :translatable_string
        f.input :description, as: :translatable_text, input_html: {rows: 5}
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
