require "rails_helper"

RSpec.describe IndividualDecorator do
  describe "#country_name" do
    it "return country's name if country is present" do
      individual = FactoryBot.build(:individual)

      individual.country = nil
      expect(individual.decorate.country_name).to eq nil

      individual.country = "INVALID"
      expect(individual.decorate.country_name).to eq nil

      individual.country = "FRA"
      expect(individual.decorate.country_name).to eq "France"
    end
  end

  describe "#greetings" do
    it "return salutations with first name if present" do
      individual = FactoryBot.build(:individual)

      expect(individual.decorate.greetings).to eq "Bonjour, Jane."
    end

    it "return salutations if first name not present" do
      individual = FactoryBot.build(:individual, first_name: "")

      expect(individual.decorate.greetings).to eq "Bonjour."
    end
  end

  describe "#current_job_short" do
    it "returns 45 first characters of current job" do
      individual = FactoryBot.build(:individual,
        current_job: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor")

      expect(individual.decorate.current_job_short.length).to eq 45
      expect(individual.decorate.current_job_short).to eq("Lorem ipsum dolor sit amet, consectetur adipi")
    end

    it "returns nil if the individual has no current job" do
      individual = FactoryBot.build(:individual, current_job: nil)

      expect(individual.decorate.current_job_short).to be nil
    end
  end

  describe "#completion_rate" do
    let(:individual) do
      FactoryBot.create(:individual,
        first_name: "Jane ",
        last_name: " Doe ",
        email: "jane@email.com ",
        current_job: "Some job ",
        description: " A nice description",
        date_of_birth: "13/09/1986",
        country: "France",
        reasons_to_join: " Because... ")
    end

    it "returns 0.8 if all fields are completed except picture" do
      expect(individual.decorate.completion_rate).to eq 0.8
    end

    it "returns 1 if all fields are completed" do
      individual.picture.attach(
        io: File.open(Rails.root.join("spec/support/assets/picture-profile.jpg")),
        filename: "profile.jpg"
      )

      expect(individual.decorate.completion_rate).to eq 1
    end
  end

  describe "#refund_link" do
    before(:each) do
      @individual = FactoryBot.create(:individual,
        email: "new.individual@gmail.com",
        address: "1 rue du Chariot d'Or",
        zip_code: "69004",
        city: "Lyon",
        date_of_birth: "23/06/1994")
      @purchase = FactoryBot.create(:shares_purchase, status: "completed", individual: @individual)
    end

    it "should return nil if one of required attribute is missing" do
      @individual.address = nil
      expect(@individual.decorate.refund_link).to be nil

      @individual.reload
      @individual.zip_code = nil
      expect(@individual.decorate.refund_link).to be nil

      @individual.reload
      @individual.city = nil
      expect(@individual.decorate.refund_link).to be nil

      @individual.reload
      @individual.date_of_birth = nil
      expect(@individual.decorate.refund_link).to be nil
    end

    it "should return nil if individual is not a shareholder yet" do
      SharesPurchase.last.delete

      expect(@individual.decorate.refund_link).to be nil
    end

    it "should return refund_link with expected encoded params when individual is a shareholder" do
      expect(@individual.decorate.refund_link).to eq(
        "https://automate-me.typeform.com/to/W5zA0RvK?adresserue=1+rue+du+Chariot+d%27Or&cp=69004&"\
        "datenaissance=23%2F06%2F1994&mail=new.individual%40gmail.com&nom=Doe&prenom=Jane&ville=Lyon"
      )
    end
  end

  describe "#recurring_purchase_link" do
    before(:each) do
      @individual = FactoryBot.create(:individual,
        email: "new.individual@gmail.com",
        address: "1 rue du Chariot d'Or",
        zip_code: "69004",
        city: "Lyon",
        date_of_birth: "23/06/1994")
      @purchase = FactoryBot.create(:shares_purchase, status: "completed", individual: @individual)
    end

    it "should return nil if one of required attribute is missing" do
      @individual.address = nil
      expect(@individual.decorate.refund_link).to be nil

      @individual.reload
      @individual.zip_code = nil
      expect(@individual.decorate.refund_link).to be nil

      @individual.reload
      @individual.city = nil
      expect(@individual.decorate.refund_link).to be nil

      @individual.reload
      @individual.date_of_birth = nil
      expect(@individual.decorate.refund_link).to be nil
    end

    it "should return nil if individual is not a shareholder yet" do
      SharesPurchase.last.delete

      expect(@individual.decorate.recurring_purchase_link).to be nil
    end

    it "should return recurring_purchase_link with expected encoded params when individual is a shareholder" do
      expect(@individual.decorate.recurring_purchase_link).to eq(
        "https://automate-me.typeform.com/to/H3NWD1Jq?adresserue=1+rue+du+Chariot+d%27Or&cp=69004&"\
        "datenaissance=23%2F06%2F1994&mail=new.individual%40gmail.com&nom=Doe&prenom=Jane&ville=Lyon"
      )
    end
  end
end
