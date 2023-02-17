class ContentsController < ApplicationController
  skip_before_action :authenticate_user!
  layout "static"

  def redirect_to_index
    @category = Category.find_by!("categories.slug_i18n -> ? = ?", I18n.locale, params[:category].to_json)
    @tag = Tag.find_by("tags.slug_i18n -> ? = ?", I18n.locale, params[:tag].to_json) if params[:tag].present?

    fullpath = contents_path(category: @category.slug, tag: @tag&.slug)
    redirect_to fullpath, status: :moved_permanently
  end

  def index
    @category = Category.eager_load(:tags).find_by!("categories.slug = ?", params[:category])
    @contents = Content.distinct.ordered_and_published.joins(:category).with_cover
      .where("categories.slug = ?", params[:category])
    @url_params = -> { {category: @category.slug, allow_locale: @category.allow_locale?} }

    @tag = Tag.find_by(slug: params[:tag]) if params[:tag].present?
    if @tag.present?
      @contents = @contents.joins(:tags).where("tags.slug = ?", params[:tag])
      @url_params = -> { {category: @category.slug, tag: @tag.slug, allow_locale: @tag.allow_locale?} }
    end

    @contents = @contents.page(params[:page])

    if [Category::MEDIA_TITLE, Category::BLOG_TITLE].include? @category.title
      @highlighted = ContentHighlighter.new(@category, @contents).find_highlight&.decorate
      @contents = ContentDecorator.decorate_collection(@contents.to_a - [@highlighted])
      render "blog_media_index"
    end
  end

  def redirect_to_show
    @content = Content.find_by!("slug_i18n -> ? = ?", I18n.locale, params[:slug].to_json)&.decorate

    fullpath = content_path(category: @content.category.slug, slug: @content.slug)
    redirect_to fullpath, status: :moved_permanently
  end

  def show
    @content = Content.includes(:call_to_action).find_by!(slug: params[:slug])&.decorate

    @url_params = -> { {category: @content.category.slug, slug: @content.slug, allow_locale: @content.allow_locale?} }
  end
end
