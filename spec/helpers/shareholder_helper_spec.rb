require "rails_helper"

describe ShareholderHelper do
  describe "#shareholder_show_path" do
    it "render user shareholder path if shareholder's type is an individual" do
      individual = FactoryBot.create(:individual, is_displayed: true)

      expect(helper.shareholder_show_path(individual)).to eq(shareholder_individual_show_path(individual, locale: :fr))
    end

    it "render company shareholder path if shareholder's type is a company" do
      company = FactoryBot.create(:company, is_displayed: true)

      expect(helper.shareholder_show_path(company)).to eq(shareholder_company_show_path(company, locale: :fr))
    end

    it "raises an error if shareholder is neither an individual nor a company" do
      user = FactoryBot.create(:user)

      expect { helper.shareholder_show_path(user) }.to raise_error("Unknown class")
    end
  end

  describe "#card_class" do
    it "render single card class if shareholder is an Individual" do
      shareholder = FactoryBot.create(:individual, is_displayed: true)

      expect(helper.card_class(shareholder)).to eq("ShareholderCard")
    end

    it "render card class with modifier if shareholder is a Company" do
      admin = FactoryBot.create(:user)
      shareholder = FactoryBot.create(:company, admin: admin, is_displayed: true)

      expect(helper.card_class(shareholder)).to eq("ShareholderCard ShareholderCard--company")
    end

    it "raises an error if shareholder is neither an individual nor a company" do
      user = FactoryBot.create(:user)

      expect { helper.card_class(user) }.to raise_error("Unknown class")
    end
  end

  describe "#roles" do
    it "render hash with roles names when individual has less than 3 roles" do
      individual = FactoryBot.create(:individual, is_displayed: true)
      role_1 = FactoryBot.create(:role, position: 2)
      role_2 = FactoryBot.create(:role, position: 1)

      individual.roles = [role_1, role_2]

      expect(helper.roles(individual)).to eq([role_2.name, role_1.name])
    end

    it "render two first roles names and last index with + when individual has more than 2 roles" do
      individual = FactoryBot.create(:individual, is_displayed: true)
      role_1 = FactoryBot.create(:role, position: 2)
      role_2 = FactoryBot.create(:role, position: 1)
      role_3 = FactoryBot.create(:role, position: 3)
      role_4 = FactoryBot.create(:role, position: 4)

      individual.roles = [role_1, role_2, role_3, role_4]

      expect(helper.roles(individual)).to eq([role_2.name, role_4.name, "+2"])
    end

    it "add 'company' tag in second position when shareholder is a company" do
      shareholder = FactoryBot.create(:company)
      role_1 = FactoryBot.create(:role, position: 1)
      role_5 = FactoryBot.create(:role, position: 5)

      shareholder.roles = [role_1, role_5]

      expect(helper.roles(shareholder)).to eq([role_1.name, "Entreprise", "+1"])
    end

    it "add 'company' tag in first position when shareholder is a company and it has no roles" do
      shareholder = FactoryBot.create(:company)

      expect(helper.roles(shareholder)).to eq(["Entreprise"])
    end
  end

  describe "#asset_description_text_or_html" do
    it "shouldn't fail when description is false" do
      expect(helper.asset_description_text_or_html(nil)).to be nil
    end
  end

  describe "#picture" do
    it "renders url for individual's variant picture" do
      individual = FactoryBot.create(:individual, :with_picture)

      expect(picture(individual, [200, 200])).to eq(url_for(individual.picture.variant(resize_to_limit: [200, 200])))
    end

    it "render fallback picture when individual has no attachment" do
      individual = FactoryBot.create(:individual)

      expect(picture(individual, [200, 200])).to eq("/default-user.png")
    end

    it "renders url for company's variant logo" do
      company = FactoryBot.create(:company, :with_logo)

      expect(picture(company, [200, 200])).to eq(url_for(company.logo.variant(resize_to_limit: [200, 200])))
    end

    it "render fallback picture when company has no attachment" do
      company = FactoryBot.create(:company)

      expect(picture(company, [200, 200])).to eq("/building-purple.svg")
    end
  end

  describe "#roles_full_list" do
    it "returns all roles by position and with owned roles first" do
      individual = FactoryBot.create(:individual)
      role_1 = FactoryBot.create(:role, position: 3)
      role_2 = FactoryBot.create(:role, position: 2)
      role_3 = FactoryBot.create(:role, position: 1)
      individual.roles = [role_1, role_3]

      expect(roles_full_list(individual)).to eq([role_3, role_1, role_2])
    end
  end

  describe "#countries_collection" do
    it "returns an ordered list of countries with names and country codes" do
      countries_list = ["MNG", "AZE", "SLE"]

      expect(countries_collection(countries_list))
        .to eq([["Azerbaïdjan", "AZE"], ["Mongolie", "MNG"], ["Sierra Leone", "SLE"]])
    end

    it "returns an ordered list of countries even if they are accented characters" do
      countries_list = ["MNG", "AZE", "USA"]

      expect(countries_collection(countries_list))
        .to eq([["Azerbaïdjan", "AZE"], ["États-Unis", "USA"], ["Mongolie", "MNG"]])
    end
  end

  describe "#shareholder_display_name" do
    it "displays the shareholder's full name if they are an individual" do
      individual = FactoryBot.create(:individual, first_name: "Jane", last_name: "Doe")

      expect(shareholder_display_name(individual)).to eq("Jane Doe")
    end

    it "displays the shareholder's name if they are a company" do
      company = FactoryBot.create(:company, name: "Umbrella Inc")

      expect(shareholder_display_name(company)).to eq("Umbrella Inc")
    end

    it "raises an error if shareholder is neither an individual nor a company" do
      user = FactoryBot.create(:user)

      expect { helper.shareholder_display_name(user) }.to raise_error("Unknown class")
    end
  end
end
