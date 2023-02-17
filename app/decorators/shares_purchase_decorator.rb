class SharesPurchaseDecorator < ApplicationDecorator
  delegate_all

  def buyer_display_name
    if object.company_info.present? && object.company_id.blank? && object.individual&.is_displayed
      object.company_info["name"]
    elsif object.company_info.present? && object.company_id.present? && object.company.is_displayed
      object.company.name
    elsif object.company_info.present?
      I18n.t("become_shareholder.tops.anonymous_company")
    elsif object.company_info.blank? && !object.individual&.is_displayed
      I18n.t("become_shareholder.tops.anonymous")
    else
      object.individual.full_name
    end
  end

  def type
    if object.company_info.nil?
      {
        value: I18n.t("private_space.investments.list.type.individual"),
        css_class: "lagoon"
      }
    else
      {
        value: I18n.t("private_space.investments.list.type.company"),
        css_class: "purple"
      }
    end
  end
end
