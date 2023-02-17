module ContentHelper
  def custom_content_path(content)
    available_locale = available_locale(content)
    content_path(
      category: content.category.slug,
      slug: content.slug,
      locale: available_locale
    )
  end

  def custom_content_url(content)
    content_url(
      category: content.category.slug,
      slug: content.slug,
    )
  end

  def tag_path(tag)
    if tag_selected?(tag)
      contents_path(category: tag.category.slug)
    else
      contents_path(category: tag.category.slug, tag: tag.slug)
    end
  end

  def tag_selected?(tag)
    params[:tag] == tag.slug
  end

  def tag_class(tag, base_class)
    if tag_selected?(tag)
      "#{base_class} #{base_class}--selected"
    else
      base_class
    end
  end

  def contents_path_without_fallback(category)
    locale = available_locale(category)
    contents_path(category: category.slug, locale: locale) if locale == I18n.locale
  end

  def contents_path_with_fallback(category)
    locale = available_locale(category)
    contents_path(category: category.slug, locale: locale)
  end

  def available_locale(record)
    [I18n.locale, :en, :fr].find do |locale|
      record.allow_locale?(locale)
    end || :fr
  end

  def content_cover_image(content, size)
    if content.cover_image.attached?
      url_for(content.cover_image.variant(resize_to_limit: size))
    else
      image_url "logo-time-planet.png"
    end
  end
end
