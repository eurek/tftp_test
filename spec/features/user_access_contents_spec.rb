require "rails_helper"

feature "user access contents" do
  include ContentHelper

  context "filtered" do
    scenario "by category" do
      category1 = FactoryBot.create(:category, published: true)
      category2 = FactoryBot.create(:category, published: true)
      content1 = FactoryBot.create(:content, status: "published", category: category1)
      content2 = FactoryBot.create(:content, status: "published", category: category2)

      visit contents_path(category: category1.slug, locale: :fr)

      expect(page).to have_content(content1.short_title.upcase_first)
      expect(page).not_to have_content(content2.short_title.upcase_first)
    end

    scenario "sees content published in english if not published in current locale" do
      category = FactoryBot.create(:category, published: true)
      content = FactoryBot.create(:content, status: "draft", category: category)
      I18n.with_locale(:es) { category.update(published: true) }
      I18n.with_locale(:en) { content.update(status: "published", slug: "content-en-slug") }

      visit contents_path(category: category.slug, locale: :es)

      expect(page).to have_content(content.short_title.upcase_first)
    end

    scenario "by category and sees only tags published in current locale" do
      category = FactoryBot.create(:category, published: true)
      tag1 = FactoryBot.create(:tag, category: category, published: true)
      tag2 = FactoryBot.create(:tag, category: category)

      visit contents_path(category: category.slug, locale: :fr)

      expect(page).to have_content(tag1.name)
      expect(page).not_to have_content(tag2.name)
    end

    scenario "can filter categorized contents with tag" do
      category = FactoryBot.create(:category, published: true)
      tag1 = FactoryBot.create(:tag, category: category, published: true)
      tag2 = FactoryBot.create(:tag, category: category, published: true)
      content1 = FactoryBot.create(:content_with_category_and_tag, status: "published", category: category, tag: tag1)
      content2 = FactoryBot.create(:content_with_category_and_tag, status: "published", category: category, tag: tag2)

      visit contents_path(category: category.slug, tag: tag1.slug, locale: :fr)

      expect(page).to have_content(content1.short_title.upcase_first)
      expect(page).not_to have_content(content2.short_title.upcase_first)
    end

    scenario "can deselect tag and come back to category filter only" do
      category = FactoryBot.create(:category, published: true)
      tag = FactoryBot.create(:tag, category: category, published: true)
      FactoryBot.create(:content_with_category_and_tag, status: "published", category: category, tag: tag)

      visit contents_path(category: category.slug, tag: tag.slug, locale: "fr")
      click_link tag.name

      expect(current_path).to eq(contents_path(category: category.slug, locale: "fr"))
    end

    scenario "raises not found error if category is not found" do
      expect {
        visit contents_path(category: "unknown-slug")
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "language switcher" do
    before(:each) do
      Mobility.with_locale(:en) do
        FactoryBot.create(:translation, key: "common.language", value: "english")
      end
    end

    scenario "can switch language on category page", js: true do
      category = FactoryBot.create(:category, published: true)
      content = FactoryBot.create(:content, status: "published", category: category)
      Mobility.with_locale(:en) do
        category.update(published: true)
        content.update(status: "published")
      end

      visit contents_path(category: category.slug, locale: :fr)
      expect(page).to have_content(content.short_title.upcase_first)

      click_button "fr", visible: true
      click_link "english"

      expect(current_path).to eq("/en/about/#{category.slug}")
      expect(page).to have_content(content.short_title.upcase_first)
    end

    scenario "cannot switch language on category page if category is not published for other locale", js: true do
      category = FactoryBot.create(:category, published: true)
      content = FactoryBot.create(:content, status: "published", category: category)

      visit contents_path(category: category.slug, locale: :fr)
      expect(page).to have_content(content.short_title.upcase_first)

      click_button "fr", visible: true
      expect(page).not_to have_content("english")
    end

    scenario "can switch language with tag filter activated", js: true do
      category = FactoryBot.create(:category, published: true)
      tag = FactoryBot.create(:tag, category: category, published: true)
      content = FactoryBot.create(:content, status: "published", category: category)
      content.tags << tag
      Mobility.with_locale(:en) do
        category.update(published: true)
        tag.update(published: true)
        content.update(status: "published", short_title: "English short title")
      end

      visit contents_path(category: category.slug, tag: tag.slug, locale: :fr)
      expect(page).to have_content(content.short_title.upcase_first)

      click_button "fr"
      click_link "english"

      expect(page).to have_current_path(
        contents_path(category: category.slug, tag: tag.slug, locale: :en)
      )
      expect(page).to have_content(content.short_title(locale: :en).upcase_first)
    end

    scenario "can switch language with activated tag filter even if tag is not published in other locale", js: true do
      category = FactoryBot.create(:category, published: true)
      tag = FactoryBot.create(:tag, category: category, published: true)
      content = FactoryBot.create(:content, status: "published", category: category)
      content.tags << tag
      Mobility.with_locale(:en) do
        category.update(published: true)
        content.update(status: "published")
      end

      visit contents_path(category: category.slug, tag: tag.slug, locale: :fr)
      expect(page).to have_content(content.short_title.upcase_first)

      click_button "fr"
      click_link "english"

      expect(page).to have_current_path(
        contents_path(category: category.slug, tag: tag.slug, locale: :en)
      )
      expect(page).to have_content(content.short_title.upcase_first)
    end

    scenario "can switch language on content page", js: true do
      category = FactoryBot.create(:category, published: true)
      content = FactoryBot.create(:content, status: "published", category: category)
      Mobility.with_locale(:en) do
        category.update(published: true)
        content.update(status: "published", title: "English title")
      end

      visit custom_content_path(content)
      expect(page).to have_content(content.title)

      click_button "fr"
      click_link "english"

      expect(current_path).to eq(
        "/en/about/#{category.slug}/#{content.slug}"
      )
      expect(page).to have_content(content.title(locale: :en).upcase_first)
    end

    scenario "cannot switch to a language in which content is not published", js: true do
      category = FactoryBot.create(:category, published: true)
      content = FactoryBot.create(:content, status: "published", category: category)
      Mobility.with_locale(:en) do
        category.update(published: true)
        content.update(status: "draft")
      end

      visit custom_content_path(content)
      expect(page).to have_content(content.title)

      click_button "fr"
      expect(page).not_to have_content("english")
    end
  end
end
