require "rails_helper"

# SEO related tests
feature "search engine access contents" do
  include ContentHelper

  scenario "by category and sees relevant meta tags and text" do
    category = FactoryBot.create(:category, published: true)

    visit contents_path(category: category.slug)

    expect(page.title).to eq("#{category.meta_title} | Time for the Planet®")
    expect(find('meta[name="title"]', visible: false)["content"]).to eq("#{category.meta_title} | Time for the Planet®")
    expect(find('meta[name="description"]', visible: false)["content"]).to eq(category.meta_description)
    expect(page).not_to have_selector('meta[name="robots"]')
    expect(page).to have_content(category.description)
  end

  scenario "by category on page 2 and does not see category description" do
    category = FactoryBot.create(:category)
    FactoryBot.create(:content, status: "published", category: category)
    FactoryBot.create(:content, status: "published", category: category)
    Content.paginates_per 1

    visit contents_path(category: category.slug)
    click_link "2"

    expect(page).not_to have_content(category.description)
    Content.paginates_per 60
  end

  it "on a content sees fallbacks when meta title and meta description are not present in current locale" do
    content = FactoryBot.create(:content, status: "published", meta_title: nil, meta_description: nil, body:
      "<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et "\
      "dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex "\
      "ea commodo consequat.</p>")
    Mobility.with_locale(:en) { content.update(meta_title: "foo", meta_description: "bar") }

    visit custom_content_path(content)

    expect(page.title).to eq("#{content.title} | Time for the Planet®")
    expect(find('meta[name="title"]', visible: false)["content"]).to eq("#{content.title} | Time for the Planet®")
    expect(find('meta[name="description"]', visible: false)["content"]).to eq(
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et "\
      "dolore magna aliqua. Ut enim ad minim veniam, quis nostrud"
    )
  end

  describe "on shareholder show page" do
    scenario "with picture and description" do
      individual = FactoryBot.create(:individual,
        first_name: "Jane",
        last_name: "Doe",
        description: "Hello, I'am a web developer")

      file_path = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")
      individual.picture.attach(io: File.open(file_path), filename: "profile.jpg")
      individual.save

      visit shareholder_individual_show_path(individual, locale: "fr")

      expect(find('meta[name="title"]', visible: false)["content"]).to eq("Jane Doe | Time for the Planet®")
      expect(find('meta[name="description"]', visible: false)["content"]).to eq("Hello, I'am a web developer")
      expect(find('meta[property="og:image"]', visible: false)["content"]).to include("profile.jpg")
    end

    scenario "without picture and description" do
      individual = FactoryBot.create(:individual, first_name: "Jane", last_name: "Doe")

      visit shareholder_individual_show_path(individual, locale: "fr")

      expect(find('meta[name="title"]', visible: false)["content"]).to eq("Jane Doe | Time for the Planet®")
      expect(find('meta[name="description"]', visible: false)["content"]).to eq("")
      expect(find('meta[property="og:image"]', visible: false)["content"]).to include("default-user")
    end
  end

  describe "on company show page" do
    scenario "with picture and description" do
      company = FactoryBot.create(:company, :with_admin, name: "Company Inc")

      file_path = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")
      company.logo.attach(io: File.open(file_path), filename: "profile.jpg")
      company.description = "We are the Company Inc"
      company.save

      visit shareholder_company_show_path(company, locale: "fr")

      expect(find('meta[name="title"]', visible: false)["content"]).to eq("Company Inc | Time for the Planet®")
      expect(find('meta[name="description"]', visible: false)["content"]).to eq("We are the Company Inc")
      expect(find('meta[property="og:image"]', visible: false)["content"]).to include("profile.jpg")
    end

    scenario "without picture and description" do
      company = FactoryBot.create(:company, :with_admin, name: "Company Inc")

      visit shareholder_company_show_path(company, locale: "fr")

      expect(find('meta[name="title"]', visible: false)["content"]).to eq("Company Inc | Time for the Planet®")
      expect(find('meta[name="description"]', visible: false)["content"]).to eq("")
      expect(find('meta[property="og:image"]', visible: false)["content"]).to include("building-purple")
    end
  end

  describe "on home page" do
    scenario "meta data image (in french)" do
      visit root_path(locale: "fr")

      expect(find('meta[property="og:image"]', visible: false)["content"]).to include("fr")
    end

    scenario "meta data image (in english)" do
      visit root_path(locale: "en")

      expect(find('meta[property="og:image"]', visible: false)["content"]).to include("en")
    end
  end
end
