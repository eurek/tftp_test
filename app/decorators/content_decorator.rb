class ContentDecorator < ApplicationDecorator
  delegate_all

  def meta_title_with_fallback
    if object.meta_title(fallback: false).present?
      h.strip_tags(object.meta_title)
    else
      h.strip_tags(object.title)
    end
  end

  def meta_description_with_fallback
    if object.meta_description(fallback: false).present?
      h.strip_tags(object.meta_description)
    elsif object.body.present?
      h.strip_tags(object.body)[0..160]
    end
  end

  def call_to_action
    if object.call_to_action.present?
      object.call_to_action
    else
      object.call_to_action = CallToAction.find_by(
        id: ENV["DEFAULT_CTA_ID"] || Rails.application.credentials.dig(:default_cta_id)
      )
    end
  end
end
