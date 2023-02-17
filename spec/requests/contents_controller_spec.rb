require "rails_helper"

RSpec.describe ContentsController, type: :request do
  describe "index" do
    it "loads data in O(1)" do
      category = create(:category, published: true)
      test_sql_predictability(
        -> { FactoryBot.create(:content, :with_cover, category: category, status: "published") },
        -> { get contents_path({category: category.slug, locale: :fr}) }
      )
    end
  end

  describe "redirect_to_index" do
    it "redirects to contents index with english slug" do
      category = FactoryBot.create(:category, published: true, slug_i18n: {fr: "slug-francais"})

      get "/fr/tout-savoir/#{category.slug_i18n["fr"]}"

      expect(response.status).to eq 301
      expect(response).to redirect_to("/fr/about/#{category.slug}")
    end
  end

  describe "redirect_to_show" do
    it "redirects to content show with english slug" do
      category = FactoryBot.create(:category, published: true, slug_i18n: {fr: "slug-francais"})
      content = FactoryBot.create(:content,
        status: "published", slug_i18n: {fr: "content-slug-francais"}, category: category)

      get "/fr/tout-savoir/#{category.slug_i18n["fr"]}/#{content.slug_i18n["fr"]}"

      expect(response.status).to eq 301
      expect(response).to redirect_to("/fr/about/#{category.slug}/#{content.slug}")
    end
  end
end
