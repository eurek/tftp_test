require "rails_helper"

feature "user access a content" do
  scenario "does not fail when content has no body" do
    content = FactoryBot.create(:content, status: "published", body: nil)

    visit content_path(category: content.category.slug, slug: content.slug)

    expect(page.status_code).to eq(200)
  end

  scenario "does not fail when DEFAULT_CTA_ID does not exist" do
    content = FactoryBot.create(:content, status: "published")
    ENV["DEFAULT_CTA_ID"] = "wrong_id"

    visit content_path(category: content.category.slug, slug: content.slug)

    expect(page.status_code).to eq(200)
  end

  scenario "does not fail when category is not published" do
    content = FactoryBot.create(:content_with_category_and_tag, status: "published", body: nil)
    content.category.update(published: false)

    visit content_path(category: content.category.slug, slug: content.slug)

    expect(page.status_code).to eq(200)
  end
end
