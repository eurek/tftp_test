class BadgeDecorator < ApplicationDecorator
  delegate_all

  def picture_dark
    if object.picture_dark.attached?
      object.picture_dark
    else
      "default-badge-dark.png"
    end
  end

  def picture_light
    if object.picture_light.attached?
      object.picture_light
    else
      "default-badge-light.png"
    end
  end
end
