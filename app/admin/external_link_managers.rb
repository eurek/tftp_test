ActiveAdmin.register ExternalLinkManager do
  menu parent: :static_pages, priority: 3

  config.filters = false
  actions :all, except: [:new, :destroy]
  permit_params :shares_purchase_form, :company_shares_purchase_form, :offer_shares_form, :company_offer_shares_form,
    :contact_form, :b2b_contact_form, :climate_deal_meeting_form, :innovation_proposal_form,
    :summary_information_document, :report_video, :climate_deal_presentation_document, :climate_deal_simulator_form,
    :galaxy_training_event, :galaxy_app, :time_app, :linkedin

  index do
    column_without_fallback :shares_purchase_form
    column_without_fallback :offer_shares_form
    column_without_fallback :company_offer_shares_form
    column_without_fallback :contact_form
    column_without_fallback :b2b_contact_form
    column_without_fallback :innovation_proposal_form
    column_without_fallback :summary_information_document
    column_without_fallback :report_video
    column_without_fallback :galaxy_training_event
    column_without_fallback :galaxy_app
    column_without_fallback :time_app
    column_without_fallback :climate_deal_presentation_document
    column_without_fallback :climate_deal_simulator_form
    column_without_fallback :climate_deal_meeting_form
    column_without_fallback :company_shares_purchase_form
    column_without_fallback :linkedin
    actions
  end

  show do
    attributes_table do
      row_without_fallback :shares_purchase_form
      row_without_fallback :company_shares_purchase_form
      row_without_fallback :offer_shares_form
      row_without_fallback :company_offer_shares_form
      row_without_fallback :contact_form
      row_without_fallback :b2b_contact_form
      row_without_fallback :climate_deal_meeting_form
      row_without_fallback :innovation_proposal_form
      row_without_fallback :summary_information_document
      row_without_fallback :report_video
      row_without_fallback :climate_deal_presentation_document
      row_without_fallback :climate_deal_simulator_form
      row_without_fallback :galaxy_training_event
      row_without_fallback :galaxy_app
      row_without_fallback :time_app
      row_without_fallback :linkedin
    end

    attributes_table title: "Metadata" do
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors # shows errors on :base

    f.inputs do
      panel "Individuals" do
        f.input :shares_purchase_form, as: :translatable_string
        f.input :offer_shares_form, as: :translatable_string
      end
      panel "Companies" do
        f.input :company_shares_purchase_form, as: :translatable_string
        f.input :company_offer_shares_form, as: :translatable_string
        f.input :climate_deal_meeting_form, as: :translatable_string
        f.input :climate_deal_presentation_document, as: :translatable_string
        f.input :climate_deal_simulator_form, as: :translatable_string
        f.input :report_video, as: :translatable_string
      end
      panel "Galaxy" do
        f.input :galaxy_training_event, as: :translatable_string
        f.input :galaxy_app, as: :translatable_string
      end
      panel "Contact forms" do
        f.input :contact_form, as: :translatable_string
        f.input :b2b_contact_form, as: :translatable_string
      end
      panel "Other" do
        f.input :innovation_proposal_form, as: :translatable_string
        f.input :summary_information_document, as: :translatable_string
        f.input :time_app, as: :translatable_string
        f.input :linkedin, as: :translatable_string
      end
    end

    f.actions # adds the 'Submit' and 'Cancel' buttons
  end
end
