class ExternalLinkManager < ApplicationRecord
  extend Mobility
  translates :shares_purchase_form, :offer_shares_form, :company_offer_shares_form, :contact_form,
    :b2b_contact_form, :climate_deal_meeting_form, :innovation_proposal_form, :summary_information_document,
    :climate_deal_simulator_form, :report_video, :climate_deal_presentation_document, :galaxy_training_event,
    :company_shares_purchase_form, :use_gift_coupon, :galaxy_app, :time_app, :linkedin
end
