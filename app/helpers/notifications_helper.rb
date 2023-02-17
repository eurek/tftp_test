module NotificationsHelper
  def variation_direction(variation)
    if variation&.negative?
      "down"
    else
      "up"
    end
  end

  def variation_symbol(variation)
    if variation.blank? || variation == 0
      ""
    elsif variation.negative?
      "-"
    else
      "+"
    end
  end
end
