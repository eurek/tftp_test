require "rails_helper"

RSpec.describe Company, type: :model do
  describe "validations" do
    subject { FactoryBot.build(:company) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:public_slug) }
    it { is_expected.to belong_to(:admin).optional.class_name("User").with_foreign_key("admin_id") }
    it { is_expected.to belong_to(:creator).optional.class_name("User").with_foreign_key("creator_id") }
    it {
      is_expected.to have_many(:employees).dependent(:nullify).class_name("Individual").with_foreign_key("employer_id")
    }
    it { is_expected.to have_many(:shares_purchases).dependent(:nullify) }
    it { is_expected.to have_many(:accomplishments).dependent(:destroy) }
    it { is_expected.to have_many(:badges).through(:accomplishments) }
    it { is_expected.to have_many(:role_attributions).dependent(:destroy) }
    it { is_expected.to have_many(:roles).through(:role_attributions) }

    it "has a default public slug" do
      company = FactoryBot.create(:company, public_slug: nil)

      expect(company.public_slug).to match ShortKey.format_regex
    end

    describe "model scopes" do
      it "to_display" do
        user = FactoryBot.create(:user)

        company = FactoryBot.create(:company, admin: user, creator: user, is_displayed: false)
        expect(Company.to_display).to eq([])

        company.update(is_displayed: true, admin: nil, creator: nil)
        expect(Company.to_display).to eq([])

        company.update(admin: user)
        expect(Company.to_display).to eq([company])

        company.update(admin: nil, creator: user)
        expect(Company.to_display).to eq([company])
      end
    end

    describe "logo" do
      it "should not be valid if logo is a heif" do
        file_path = Rails.root.join("spec", "support", "assets", "profile.heif")
        subject.logo.attach(io: File.open(file_path), filename: "profile.heif")
        subject.save

        expect(subject.errors["logo"]).to eq(["logo doit être au format jpg, jpeg ou png"])
      end

      it "should be valid if logo is a jpg" do
        file_path = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")
        subject.logo.attach(io: File.open(file_path), filename: "profile.jpg")
        subject.save

        expect(subject.errors["logo"]).to be_empty
      end
    end
  end

  describe "to_param" do
    it "generate a url using the company's name" do
      company = FactoryBot.create(:company, name: "Some company")

      expect(company.to_param).to eq("#{company.public_slug}-some-company")
    end
  end

  describe "make_links_absolute" do
    it "save absolute link when user entered only domain" do
      company = FactoryBot.create(:company,
        website: "nada.computer",
        facebook: "facebook.com",
        linkedin: "linkedin.com")

      expect(company.website).to eq("https://nada.computer")
      expect(company.facebook).to eq("https://facebook.com")
      expect(company.linkedin).to eq("https://linkedin.com")
    end

    it "does nothing when links are already absolute" do
      company = FactoryBot.create(:company,
        website: "https://www.nada.computer",
        facebook: "https://www.facebook.com",
        linkedin: "https://www.linkedin.com")

      expect(company.website).to eq("https://www.nada.computer")
      expect(company.facebook).to eq("https://www.facebook.com")
      expect(company.linkedin).to eq("https://www.linkedin.com")
    end
  end

  it "trims required attributes" do
    company = FactoryBot.create(:company,
      name: "Time ",
      address: " 10 Rue De Bellecordière, 69002 Lyon ",
      city: "Lyon ",
      street_address: " 10 Rue De Bellecordière ")

    company = company.reload
    expect(company.name).to eq("Time")
    expect(company.address).to eq("10 Rue De Bellecordière, 69002 Lyon")
    expect(company.city).to eq("Lyon")
    expect(company.street_address).to eq("10 Rue De Bellecordière")
  end

  it "titleizes required attributes" do
    company = FactoryBot.create(:company,
      address: "10 rue De bellecordière, 69002 lyon",
      city: "lyon",
      street_address: "10 Rue de bellecordière")

    company = company.reload
    expect(company.address).to eq("10 Rue De Bellecordière, 69002 Lyon")
    expect(company.city).to eq("Lyon")
    expect(company.street_address).to eq("10 Rue De Bellecordière")
  end

  describe "#geocodable_address" do
    it "returns full address street_address is present" do
      company = FactoryBot.create(:company,
        street_address: "58 Rue Jean Moulin",
        zip_code: "31130",
        city: "Balma",
        country: "France")

      expect(company.send("geocodable_address")).to eq("58 Rue Jean Moulin 31130 Balma France")
    end

    it "returns address if street_address is not present" do
      company = FactoryBot.create(:company, address: "58 Rue Jean Moulin 31130 Balma Occitanie France")

      expect(company.send("geocodable_address")).to eq("58 Rue Jean Moulin 31130 Balma Occitanie France")
    end

    it "returns nil if neither street_address nor address is present" do
      company = FactoryBot.create(:company)

      expect(company.send("geocodable_address")).to be nil
    end
  end

  describe "geocoding" do
    it "geocodes when adding an address" do
      company = FactoryBot.create(:company)

      company.update(address: "Lyon")

      expect(Company.last.latitude).to eq(45.7484600)
      expect(Company.last.longitude).to eq(4.8467100)
    end

    it "geocodes when changing an address" do
      company = FactoryBot.create(:company, address: "Lyon")

      company.update(address: "Paris")

      expect(Company.last.latitude).to eq(48.8534100)
      expect(Company.last.longitude).to eq(2.3488000)
    end

    it "adds the country" do
      FactoryBot.create(:company, address: "Lyon")

      expect(Company.last.country).to eq("FRA")
    end
  end

  describe "reset_coordinates callback" do
    it "resets latitude and longitude to 0 if the adresse is changed" do
      company = FactoryBot.create(:company, address: "Lyon")

      company.update(address: "Le Havre")

      expect(Company.last.latitude).to be nil
      expect(Company.last.longitude).to be nil
    end

    it "does not reset latitude and longitude to 0 if the adresse is not changed" do
      company = FactoryBot.create(:company, address: "Lyon")

      company.update(name: "Optimiz.me")

      expect(Company.last.latitude).not_to be nil
      expect(Company.last.longitude).not_to be nil
    end
  end

  describe "country" do
    it "is normalized and validated" do
      company = FactoryBot.build(:company)

      company.country = nil
      expect(company).to be_valid

      company.country = "France"
      expect(company).to be_valid
      expect(company.country).to eq "FRA"

      company.country = "Spain"
      expect(company).to be_valid
      expect(company.country).to eq "ESP"

      company.country = "Espagne"
      expect(company).to be_valid
      expect(company.country).to eq "ESP"

      company.country = "Espana"
      expect(company).to be_valid
      expect(company.country).to eq "ESP"

      company.country = "fr"
      expect(company).to be_valid
      expect(company.country).to eq "FRA"

      company.country = "CA"
      expect(company).to be_valid
      expect(company.country).to eq "CAN"

      company.country = "ABC"
      expect(company).to be_valid # normalize country passes country to nil when country is not found
      expect(company.country).to be nil
    end
  end

  describe "deduplicate" do
    before(:each) do
      @chosen_company = FactoryBot.create(
        :company,
        name: "This Company",
        address: "1067 Quai Fulchiron, Lyon",
        website: "www.some-website.com"
      )

      @company_to_delete = FactoryBot.create(
        :company,
        name: "Not This Company",
        address: "Other Adresse",
        description: "Some description"
      )
    end

    it "assigns deleted company attribute to chosen company if attributes are nil" do
      Company.deduplicate(@chosen_company, @company_to_delete)

      expect(@chosen_company.reload.name).to eq("This Company")
      expect(@chosen_company.reload.address).to eq("1067 Quai Fulchiron, Lyon")
      expect(@chosen_company.reload.website).to eq("https://www.some-website.com")
      expect(@chosen_company.reload.description).to eq("Some description")
    end

    it "assigns all employees to chosen company" do
      @employee_1 = FactoryBot.create(:individual)
      @employee_2 = FactoryBot.create(:individual)
      @chosen_company.reload.employees << @employee_1
      @company_to_delete.reload.employees << @employee_2

      Company.deduplicate(@chosen_company, @company_to_delete)

      expect(@chosen_company.reload.employees.to_a.sort).to eq([@employee_1, @employee_2].sort)
    end

    it "assigns all shares purchases to chosen company" do
      @shares_purchase_1 = FactoryBot.create(:shares_purchase)
      @shares_purchase_2 = FactoryBot.create(:shares_purchase)
      @chosen_company.reload.shares_purchases << @shares_purchase_1
      @company_to_delete.reload.shares_purchases << @shares_purchase_2

      Company.deduplicate(@chosen_company, @company_to_delete)

      expect(@chosen_company.reload.shares_purchases.to_a.sort).to eq([@shares_purchase_1, @shares_purchase_2].sort)
    end

    it "deletes the other company" do
      Company.deduplicate(@chosen_company, @company_to_delete)

      expect(Company.all.count).to eq 1
    end
  end
end
