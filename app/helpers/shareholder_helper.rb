module ShareholderHelper
  def shareholder_show_path(shareholder)
    if shareholder.is_a? Individual
      shareholder_individual_show_path(I18n.locale, shareholder)
    elsif shareholder.is_a? Company
      shareholder_company_show_path(I18n.locale, shareholder)
    else
      raise "Unknown class"
    end
  end

  def card_class(shareholder)
    if shareholder.is_a? Individual
      "ShareholderCard"
    elsif shareholder.is_a? Company
      "ShareholderCard ShareholderCard--company"
    else
      raise "Unknown class"
    end
  end

  def roles(shareholder)
    # We aim to display "Shareholder" tag first (position 1), then the others in reverse position order
    roles = shareholder.roles
    ordered_roles = roles.select { |role| role.position == 1 } +
      roles.reject { |role| role.position == 1 }.sort_by(&:position).reverse
    ordered_tags = ordered_roles.map(&:name)
    if shareholder.class.to_s == "Company"
      ordered_tags.insert(ordered_tags.blank? ? 0 : 1, t("shareholder.index.company_stickers.sticker_2"))
    end
    tags = ordered_tags[0..1]
    if ordered_tags.size > 2
      tags << "+#{ordered_tags.size - 2}"
    end
    tags
  end

  def roles_full_list(shareholder, scope = :all)
    roles = Role.send(scope)
    owned_roles = roles.select { |role| shareholder.roles.include?(role) }.sort_by(&:position)
    other_roles = roles.reject { |role| shareholder.roles.include?(role) }.sort_by(&:position)
    owned_roles + other_roles
  end

  def asset_description_text_or_html(description)
    Nokogiri::HTML.parse(description).html? ? description&.html_safe : description
  end

  def picture(shareholder, size)
    if shareholder.is_a?(Individual) && shareholder.picture.attached? && shareholder.picture.variable?
      url_for(shareholder.picture.variant(resize_to_limit: size))
    elsif shareholder.is_a?(Individual) && shareholder.picture.attached?
      url_for(shareholder.picture)
    elsif shareholder.is_a?(Individual)
      asset_path("default-user.png")
    elsif shareholder.is_a?(Company) && shareholder.logo.attached? && shareholder.logo.variable?
      url_for(shareholder.logo.variant(resize_to_limit: size))
    elsif shareholder.is_a?(Company) && shareholder.logo.attached?
      url_for(shareholder.logo)
    else
      asset_path("building-purple.svg")
    end
  end

  def filename_short(filename)
    if filename.length > 28
      filename.truncate(28, omission: "...#{filename.last(14)}")
    else
      filename
    end
  end

  def countries_collection(countries_codes)
    countries_names = countries_codes.map do |code|
      [
        ISO3166::Country.find_country_by_alpha3(code).translations[I18n.locale.to_s] ||
          ISO3166::Country.find_country_by_alpha3(code).name,
        code
      ]
    end
    countries_names.sort_by! { |country_data| ActiveSupport::Inflector.transliterate(country_data[0]) }
  end

  def shareholder_display_name(shareholder)
    if shareholder.is_a? Individual
      shareholder.decorate.full_name
    elsif shareholder.is_a? Company
      shareholder.name
    else
      raise "Unknown class"
    end
  end
end
