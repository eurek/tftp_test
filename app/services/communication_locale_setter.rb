class CommunicationLocaleSetter
  def initialize(individual)
    @individual = individual
  end

  def set
    typeform_language = @individual.shares_purchases.last&.typeform_language&.downcase&.to_sym
    I18n.locale = if I18n.available_locales.include?(typeform_language)
      typeform_language
    elsif I18n.available_locales.include?(@individual.communication_language&.to_sym)
      @individual.communication_language&.to_sym
    else
      :fr
    end
  end
end
