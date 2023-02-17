require "rails_helper"

describe Content, type: :model do
  it { is_expected.to have_many(:tags) }
  it { is_expected.to belong_to(:category) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:slug) }
  it { is_expected.to allow_value("foo-bar-2").for(:slug) }
  it { is_expected.not_to allow_value("foo_bar").for(:slug) }

  describe "validates that a value is included in allowed values for the current locale" do
    let(:content) { FactoryBot.build(:content) }
    before { I18n.locale = :fr }

    it "handles nil attribute" do
      content.status = nil

      expect(content.valid?).to eq true
      expect(content.status_i18n).to eq({"fr" => "draft"})
    end

    it "handles empty attribute" do
      content.status_i18n = {}

      expect(content.valid?).to eq true
      expect(content.status_i18n).to eq({"fr" => "draft"})
    end

    it "handles missing variant" do
      content.status_i18n = {"en" => "published"}

      expect(content.valid?).to eq true
      expect(content.status_i18n).to eq({"en" => "published", "fr" => "draft"})
    end

    it "handles blank variant" do
      content.status_i18n = {"fr" => ""}

      expect(content.valid?).to eq true
      expect(content.status_i18n).to eq({"fr" => "draft"})
    end

    it "handles wrong variant" do
      content.status_i18n = {fr: "wrong-value"}

      expect(content.valid?).to eq false
      expect(content.errors[:status]).to eq ["'wrong-value' is not an authorized value: draft,"\
        " ready for reread, reread for translation, reread for spelling, published"]
    end

    it "handles present variant" do
      content.status_i18n = {fr: "draft"}
      expect(content.valid?).to eq true

      content.status_i18n = {"fr" => "draft"}
      expect(content.valid?).to eq true
    end
  end

  describe "set target blank on each content html link" do
    it "add target blank before saving content" do
      content = FactoryBot.build(:content)
      body = '<a href="#">LINK</a>'
      content.update!(body: body)

      expect(content.body.include?("target=\"_blank\"")).to eq(true)
    end
  end

  describe "set html elements which have an inline width to 100%" do
    it "sets elements width to 100%" do
      content = FactoryBot.build(:content)
      body = "<div width=\"50px\">content</div>"
      content.update!(body: body)

      expect(content.body.include?("width=\"100%\"")).to eq(true)
    end

    it "doesn't add a width if the element doesn't have one" do
      content = FactoryBot.build(:content)
      body = "<div>content</div>"
      content.update!(body: body)

      expect(content.body.include?("width=\"100%\"")).to eq(false)
    end
  end

  describe "related contents" do
    it "returns contents from the same category when content has no tags" do
      category = FactoryBot.create(:category, published: true)
      content1 = FactoryBot.create(:content, status: "published", category: category)
      content2 = FactoryBot.create(:content, status: "published", category: category)
      content3 = FactoryBot.create(:content, status: "draft", category: category)

      expect(content1.related_contents).to include(content2)
      expect(content1.related_contents).not_to include(content1)
      expect(content1.related_contents).not_to include(content3)
    end

    it "returns contents with the same tag when content has at least one tag" do
      tag = FactoryBot.create(:tag, published: true)
      category = FactoryBot.create(:category, published: true)
      content1 = FactoryBot.create(:content, status: "published", category: category)
      content2 = FactoryBot.create(:content, status: "published", category: category)
      content3 = FactoryBot.create(:content, status: "draft", category: category)
      [content1, content2, content3].each { |content| content.tags << tag }

      expect(content1.related_contents).to include(content2)
      expect(content1.related_contents).not_to include(content1)
      expect(content1.related_contents).not_to include(content3)
    end

    it "does not see not published related contents even if published in another locale (other than en)" do
      category = FactoryBot.create(:category, published: true)
      content1 = FactoryBot.create(:content, status: "published", category: category)
      content2 = FactoryBot.create(:content, status: "published", category: category)
      content3 = FactoryBot.create(:content, status: "draft", category: category)
      I18n.with_locale(:es) { content3.update(status: "published") }

      expect(content1.related_contents).to include(content2)
      expect(content1.related_contents).not_to include(content1)
      expect(content1.related_contents).not_to include(content3)
    end
  end
end
