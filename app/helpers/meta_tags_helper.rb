module MetaTagsHelper
  def meta_title
    if content_for(:meta_title).present?
      "#{content_for(:meta_title)} | Time for the Planet®".html_safe
    else
      "Time for the Planet®"
    end
  end

  def meta_image
    if content_for(:meta_image).present?
      content_for(:meta_image)
    elsif asset_exists?("meta_images/#{I18n.locale}.jpg")
      image_url("meta_images/#{I18n.locale}.jpg")
    else
      image_url("meta_images/en.jpg")
    end
  end

  private

  # https://github.com/rails/sprockets-rails/issues/298
  def asset_exists?(logical_path)
    if Rails.configuration.assets.compile
      # Dynamic compilation
      Rails.application.assets.find_asset(logical_path).present?
    else
      # Pre-compiled
      Rails.application.assets_manifest.assets[logical_path].present?
    end
  end
end
