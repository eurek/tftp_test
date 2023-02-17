class CompanyDecorator < ApplicationDecorator
  include Rails.application.routes.url_helpers
  delegate_all

  def completion_rate
    rate = 0.1
    rate += 0.1 if object.address.present?
    rate += 0.1 if object.description.present?
    rate += 0.1 if object.co2_emissions_reduction_actions.present?
    rate += 0.1 if object.linkedin.present?
    rate += 0.1 if object.facebook.present?
    rate += 0.1 if object.website.present?
    rate += 0.3 if object.logo.attached?
    rate
  end
end
