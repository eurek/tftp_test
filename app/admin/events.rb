ActiveAdmin.register Event do
  menu priority: 10
  actions :index, :show, :destroy
  permit_params :title, :locale, :category, :description, :date, :venue, :registration_link, :timezone

  filter :title
  filter :locale
  filter :category
  filter :date
  filter :timezone
  filter :venue
  filter :external_uid

  index do
    selectable_column
    id_column
    column :external_uid
    column :title
    column :locale
    column :category
    column :date
    column :timezone
    column :venue
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :external_uid
      row :title
      row :locale
      row :category
      row :date
      row :timezone
      row :venue
      row :registration_link
      row :description
    end

    attributes_table title: "Assets" do
      row_image :picture
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end
end
