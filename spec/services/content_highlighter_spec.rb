require "rails_helper"

describe ContentHighlighter do
  context "for media contents" do
    before(:each) do
      @time_media_category = Category.find_by(title: "time_media")
    end

    it "returns the content chosen by admin if present" do
      content = FactoryBot.create(:content, category: @time_media_category)
      highlighted_content = FactoryBot.create(:highlighted_content)
      highlighted_content.update(time_media_content_id: content.id)

      expect(ContentHighlighter.new(@time_media_category, @time_media_category.contents).find_highlight).to eq(content)
    end

    it "returns most recent content if the admin didn't chose a highlight" do
      FactoryBot.create(:content, category: @time_media_category, created_at: 3.day.ago)
      recent_content = FactoryBot.create(:content, category: @time_media_category, created_at: 2.day.ago)
      FactoryBot.create(:content, category: @time_media_category, created_at: 5.day.ago)

      expect(ContentHighlighter.new(@time_media_category, @time_media_category.contents).find_highlight)
        .to eq(recent_content)
    end
  end

  context "for blog contents" do
    before(:each) do
      @blog_category = Category.find_by(title: "blog")
    end

    it "returns the content chosen by admin if present" do
      content = FactoryBot.create(:content, category: @blog_category)
      highlighted_content = FactoryBot.create(:highlighted_content)
      highlighted_content.update(blog_content_id: content.id)

      expect(ContentHighlighter.new(@blog_category, @blog_category.contents).find_highlight).to eq(content)
    end

    it "returns most recent content if the admin didn't chose a highlight" do
      FactoryBot.create(:content, category: @blog_category, created_at: 3.day.ago)
      recent_content = FactoryBot.create(:content, category: @blog_category, created_at: 2.day.ago)
      FactoryBot.create(:content, category: @blog_category, created_at: 5.day.ago)

      expect(ContentHighlighter.new(@blog_category, @blog_category.contents).find_highlight).to eq(recent_content)
    end
  end

  it "returns nil for categories other than time media or blog" do
    random_category = FactoryBot.create(:category)
    FactoryBot.create(:content, category: random_category)

    expect(ContentHighlighter.new(random_category, random_category.contents).find_highlight).to be nil
  end
end
