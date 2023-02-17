require "rails_helper"

describe "Shareholders Controller" do
  describe "show_individual" do
    let!(:individual) { FactoryBot.create(:individual) }
    let(:user) { FactoryBot.create(:user, individual: individual) }

    def former_slug
      "#{user.id}-#{individual.first_name.parameterize}-#{individual.last_name.parameterize}"
    end

    it "matches new slug and url contains user full name" do
      get shareholder_individual_show_path(individual, locale: :en)

      expect(response.status).to eq 200
      expect(response.body).to include("#{individual.first_name} #{individual.last_name}")
      expect(response.request.path).to include(
        "#{individual.public_slug}-#{individual.first_name.parameterize}-#{individual.last_name.parameterize}"
      )
    end

    it "matches if only public_slug is present without name" do
      get shareholder_individual_show_path(slug: individual.public_slug, locale: :en)

      expect(response.status).to eq 301
      expect(response).to redirect_to(shareholder_individual_show_path(individual))
      follow_redirect!

      expect(response.status).to eq 200
      expect(response.body).to include("#{individual.first_name} #{individual.last_name}")
    end

    it "redirects to new slug if former slug is requested" do
      get shareholder_individual_show_path(slug: former_slug)
      follow_redirect!

      expect(response.status).to eq 301
      expect(response).to redirect_to(shareholder_individual_show_path(individual))
      follow_redirect!

      expect(response.body).to include("#{individual.first_name} #{individual.last_name}")
    end

    it "matches former slug if only id is present without name" do
      get shareholder_individual_show_path(slug: user.id)
      follow_redirect!

      expect(response.status).to eq 301
      expect(response).to redirect_to(shareholder_individual_show_path(individual))
      follow_redirect!

      expect(response.body).to include("#{individual.first_name} #{individual.last_name}")
    end

    it "redirects to shareholders_path when user does not want their profile public" do
      individual.update(is_displayed: false)
      get shareholder_individual_show_path(individual, locale: :en)

      expect(response.status).to eq 302
      expect(response).to redirect_to(shareholders_path)
    end
  end

  describe "show_company" do
    let(:company) { FactoryBot.create(:company, :with_admin) }

    def former_slug
      "#{company.id}-#{company.name.parameterize}"
    end

    it "matches new slug and url contains company name" do
      get shareholder_company_show_path(company, locale: :en)

      expect(response.status).to eq 200
      expect(response.body).to include(company.name)
      expect(response.request.path).to include("#{company.public_slug}-#{company.name.parameterize}")
    end

    it "matches if only public_slug is present without name" do
      get shareholder_company_show_path(slug: company.public_slug, locale: :en)

      expect(response.status).to eq 301
      expect(response).to redirect_to(shareholder_company_show_path(company))
      follow_redirect!

      expect(response.status).to eq 200
      expect(response.body).to include(company.name)
    end

    it "redirects to new slug if former slug is requested" do
      get shareholder_company_show_path(slug: former_slug)
      follow_redirect!

      expect(response.status).to eq 301
      expect(response).to redirect_to(shareholder_company_show_path(company))
      follow_redirect!

      expect(response.body).to include(company.name)
    end

    it "matches former slug if only id is present without name" do
      get shareholder_company_show_path(slug: company.id)
      follow_redirect!

      expect(response.status).to eq 301
      expect(response).to redirect_to(shareholder_company_show_path(company))
      follow_redirect!

      expect(response.body).to include(company.name)
    end

    describe "redirects to shareholders_path" do
      it "when company does not want their profile public" do
        company.update(is_displayed: false)
        get shareholder_company_show_path(company, locale: :en)

        expect(response.status).to eq 302
        expect(response).to redirect_to(shareholders_path)
      end

      it "when company does not have admin nor creator" do
        company.update(is_displayed: true, admin: nil, creator: nil)
        get shareholder_company_show_path(company, locale: :en)

        expect(response.status).to eq 302
        expect(response).to redirect_to(shareholders_path)
      end
    end
  end
end
