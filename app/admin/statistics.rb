ActiveAdmin.register Statistic do
  menu parent: :roadmap, priority: 3
  config.sort_order = "date_desc"
  permit_params :total_shareholders, :total_innovations_assessed, :total_innovations_assessors

  actions :all, except: [:new, :create]

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :date, input_html: {disabled: true}
      f.input :total_shareholders
      f.input :total_innovations_assessors
      f.input :total_innovations_assessed
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
