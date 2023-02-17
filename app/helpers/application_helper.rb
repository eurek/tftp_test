module ApplicationHelper
  def embedded_svg filename, options = {}
    file = File.read(Rails.root.join("app", "assets", "images", filename))
    doc = Nokogiri::HTML::DocumentFragment.parse file
    svg = doc.at_css "svg"
    if options[:class].present?
      svg["class"] = options[:class]
    end
    if options[:alt].present?
      svg["alt"] = options[:alt]
    end
    if options[:role].present?
      svg["role"] = options[:role]
    end
    doc.to_html.html_safe
  end

  def get_host_without_www(url)
    return if url.blank?

    uri = URI.parse(url)
    uri = URI.parse("http://#{url}") if uri.scheme.nil?
    host = uri.host.downcase
    host.start_with?("www.") ? host[4..-1] : host
  end

  def human_enum_name(record, attr)
    return unless record.send(attr).present?

    I18n.t("activerecord.attributes.#{record.model_name.i18n_key}.#{attr.to_s.pluralize}.#{record.send(attr)}")
  end

  def is_a_buying_shares_path?(path)
    [
      become_shareholder_path,
      become_shareholder_company_path,
      offer_shares_path,
      offer_shares_company_path,
      buy_shares_choice_path
    ].include?(path)
  end

  def content_index_icon(category)
    if Rails.application.assets_manifest.find_sources("icones/#{category.title}.svg").any?
      "icones/#{category.title}.svg"
    else
      "icones/shareholders.svg"
    end
  end

  def active_link_class(paths, css_class)
    paths.include?(request.path) ? "#{css_class} #{css_class}--active" : css_class
  end

  def home_persona_cta(persona)
    case persona
    when "citizen"
      become_shareholder_path
    when "company"
      become_shareholder_company_path
    when "innovator"
      submit_innovation_path
    end
  end

  def root_path_choice
    if cookies.signed[:home_choice].present? && cookies.signed[:home_choice] == "company"
      company_home_path
    else
      root_path
    end
  end
end
