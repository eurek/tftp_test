ActiveAdmin.register RoadmapTask do
  menu parent: :roadmap, priority: 1

  before_action :skip_sidebar!, only: :index
  permit_params :locale, :title, :text, :done_at, :duration_type, :category, :position, :status,
    prerequisite_task_ids: []

  filter :title
  filter :text

  includes :prerequisite_tasks

  scope :all, default: true

  RoadmapTask.statuses.values.map do |status|
    scope(status.humanize, group: :status) { |scope| scope.where(status: status) }
  end

  RoadmapTask.categories.values.map do |category|
    scope(category.humanize, group: :category) { |scope| scope.where(category: category) }
  end

  index do
    selectable_column
    id_column
    column_without_fallback :title
    column_without_fallback :text
    column :category
    column :duration_type
    column :status
    column :done_at
    column :position
    column :prerequisite_tasks
    actions
  end

  show do
    attributes_table do
      row_without_fallback :title
      row_without_fallback :text
      row :category
      row :duration_type
      row :status
      row :done_at
      row :position
      row :prerequisite_tasks
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
      f.input :text, as: :minimal_redactor, hint: f.object.text_fr
      f.input :category, as: :select, collection: RoadmapTask.categories.keys
      f.input :duration_type, as: :select, collection: RoadmapTask.duration_types.keys
      f.input :status, as: :select, collection: RoadmapTask.statuses.keys
      f.input :done_at, as: :datepicker
      f.input :position
      unless f.object.new_record?
        f.input :prerequisite_tasks
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
