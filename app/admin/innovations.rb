ActiveAdmin.register Innovation do
  menu parent: :innovations, priority: 1
  actions :index, :show, :edit, :update, :destroy
  permit_params :short_description, :problem_solved, :solution_explained, :potential_clients, :differentiating_elements,
    :displayed_on_home, :picture, funded_innovation_attributes: [
      :id, :funded_at, :company_created_at, :amount_invested, :video_link, :pitch_deck_link, :summary,
      :scientific_committee_opinion, :carbon_potential, :website, :development_stage,
      pictures: [],
      co2_reduction: {}
    ]

  filter :name
  filter :id
  filter :external_uid
  filter :status
  filter :rating
  filter :action_lever
  filter :action_domain
  filter :country
  filter :city
  filter :submitted_at

  scope :all, default: true
  scope "Displayed on Home" do |scope|
    scope.where.not(displayed_on_home: nil)
  end

  scope "Funded" do |scope|
    scope.star_status
  end

  index do
    selectable_column
    id_column
    column :name
    column :external_uid
    column :submission_episode do |resource|
      link_to(resource.submission_episode.decorate.display_code, admin_episode_path(resource.submission_episode))
    end
    if params[:scope] == "displayed_on_home"
      column :displayed_on_home
    elsif params[:scope] == "funded"
      column :amount_invested do |resource|
        resource.funded_innovation&.amount_invested
      end
      column :funded_at do |resource|
        resource.funded_innovation&.funded_at
      end
      column :funding_episode do |resource|
        link_to(
          resource.funded_innovation.funding_episode.decorate.display_code,
          admin_episode_path(resource.funded_innovation.funding_episode)
        )
      end
      column :carbon_potential do |resource|
        resource.funded_innovation&.carbon_potential(fallback: false)
      end
      column :development_stage do |resource|
        resource.funded_innovation&.development_stage
      end
      column :website do |resource|
        resource.funded_innovation&.website
      end
    else
      column :status
      column :rating
      column :action_lever
      column :action_domain
      column :country
      column :city
    end
    column :submitted_at
    actions
  end

  show do
    attributes_table do
      row :name
      row :founders
      row_without_fallback :short_description
      row_without_fallback :problem_solved
      row_without_fallback :solution_explained
      row_without_fallback :potential_clients
      row_without_fallback :differentiating_elements

      row :action_lever
      row :action_domain
      row :status
      row :selection_period
      row :submitted_at
      row :evaluations_amount
      row :rating
      row :city
      row :country
      row :language
      row :website
    end

    attributes_table title: "Additional attributes for innovations funded" do
      row :displayed_on_home
      row :funded_at do |resource|
        resource.funded_innovation&.funded_at
      end
      row :company_created_at do |resource|
        resource.funded_innovation&.company_created_at
      end
      row :amount_invested do |resource|
        resource.funded_innovation&.amount_invested
      end
      row :summary do |resource|
        resource.funded_innovation&.summary
      end
      row :scientific_committee_opinion do |resource|
        resource.funded_innovation&.scientific_committee_opinion
      end
      row :video_link do |resource|
        resource.funded_innovation&.video_link
      end
      row :pitch_deck_link do |resource|
        resource.funded_innovation&.pitch_deck_link
      end
      row :development_stage do |resource|
        resource.funded_innovation&.development_stage
      end
      row :website do |resource|
        resource.funded_innovation&.website
      end
      row :co2_reduction do |resource|
        resource.funded_innovation&.co2_reduction
      end
    end

    attributes_table title: "Assets" do
      row_image :picture
      row :pictures do
        resource.funded_innovation&.pictures&.map do |picture|
          image_tag(picture.variant(resize_to_limit: [200, 200]), class: "ImagePreview")
        end
      end
    end

    attributes_table title: "Metadata" do
      row :id
      row :external_uid
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    using_main_locale = I18n.locale == :fr

    f.semantic_errors # shows errors on :base

    f.inputs do
      f.input :displayed_on_home, as: :select
      f.input :picture, as: :image

      unless using_main_locale
        f.input :short_description, as: :translatable_text, input_html: {rows: 5}
        f.input :problem_solved, as: :translatable_text, input_html: {rows: 5}
        f.input :solution_explained, as: :translatable_text, input_html: {rows: 5}
        f.input :potential_clients, as: :translatable_text, input_html: {rows: 5}
        f.input :differentiating_elements, as: :translatable_text, input_html: {rows: 5}
      end
    end

    if f.object.star_status?
      f.object.build_funded_innovation if f.object.funded_innovation.nil?
      f.inputs for: :funded_innovation do |funded|
        panel "Funded Innovation" do
          funded.inputs do
            funded.input :funded_at
            funded.input :company_created_at
            funded.input :amount_invested
            funded.input :carbon_potential, as: :translatable_string
            funded.input :video_link
            funded.input :pitch_deck_link, as: :translatable_string
            funded.input :summary, as: :minimal_redactor, hint: f.object.funded_innovation.summary_fr
            funded.input :scientific_committee_opinion,
              as: :minimal_redactor,
              hint: f.object.funded_innovation.scientific_committee_opinion_fr
            funded.input :pictures, as: :image, input_html: {multiple: true}
            funded.input :development_stage, as: :select, collection: FundedInnovation.development_stages.keys
            funded.input :website
          end
        end

        panel "CO2 Reduction" do
          funded.inputs for: :co2_reduction do |g|
            g.inputs do
              g.input :"2022", as: :number, require: false, input_html: {value: funded.object.co2_reduction["2022"]}
              g.input :"2023", as: :number, require: false, input_html: {value: funded.object.co2_reduction["2023"]}
              g.input :"2024", as: :number, require: false, input_html: {value: funded.object.co2_reduction["2024"]}
              g.input :"2025", as: :number, require: false, input_html: {value: funded.object.co2_reduction["2025"]}
            end
          end
        end
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end

  controller do
    def scoped_collection
      super.includes(:action_domain, :action_lever, :submission_episode,
        funded_innovation: [:funding_episode, pictures_attachments: :blob])
    end
  end
end
