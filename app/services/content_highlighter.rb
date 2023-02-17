class ContentHighlighter
  def initialize(category, contents)
    @category = category
    @contents = contents
  end

  def find_highlight
    return nil unless [Category::MEDIA_TITLE, Category::BLOG_TITLE].include? @category.title

    admin_highlighted_content_id = HighlightedContent.first&.send("#{@category.title}_content_id")

    if admin_highlighted_content_id.present?
      Content.find(admin_highlighted_content_id)
    else
      @contents.max_by(&:created_at)
    end
  end
end
