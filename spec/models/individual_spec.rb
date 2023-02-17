require "rails_helper"

RSpec.describe Individual, type: :model do
  describe "validations" do
    subject { FactoryBot.build(:individual) }
    it { is_expected.to validate_uniqueness_of(:external_uid).allow_nil }
    it { is_expected.to belong_to(:employer).class_name("Company").with_foreign_key("employer_id").optional }
    it { is_expected.to have_one(:user) }
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:description).is_at_most(380) }
    it { is_expected.to have_many(:accomplishments).dependent(:destroy) }
    it { is_expected.to have_many(:badges).through(:accomplishments) }
    it { is_expected.to have_many(:role_attributions).dependent(:destroy) }
    it { is_expected.to have_many(:roles).through(:role_attributions) }
    it { is_expected.to have_many(:shares_purchases).dependent(:nullify) }
    it { is_expected.to have_many(:notifications) }

    it { is_expected.to encrypt_attribute(:first_name) }
    it {
      is_expected.to have_blind_index_for(:first_name)
        .test_with_query("Marcel")
        .matching(" mârcel ").but_not("Mar")
    }

    it { is_expected.to encrypt_attribute(:last_name) }
    it {
      is_expected.to have_blind_index_for(:last_name)
        .test_with_query("Marcel")
        .matching(" mârcel ").but_not("Mar")
    }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to encrypt_attribute(:email).sample_value("test@example.com") }
    it {
      is_expected.to have_blind_index_for(:email)
        .test_with_query(" test@example.COM ")
        .matching("test@example.com").but_not("test@example.co", "test@exâmple.com")
    }

    it { is_expected.to encrypt_attribute(:phone) }
    it {
      is_expected.to have_blind_index_for(:phone)
        .test_with_query("0600112233")
        .matching(" +33 6 00 11 22 33").but_not("+33 6")
    }

    it { is_expected.to encrypt_attribute(:date_of_birth).sample_value(Date.new(1990, 9, 8)) }
    it {
      is_expected.to have_blind_index_for(:date_of_birth)
        .test_with_query(Date.new(1990, 9, 8))
        .matching(Date.new(1990, 9, 8)).but_not(Date.new(2020, 9, 8))
    }

    it { is_expected.to encrypt_attribute(:address) }
    it { is_expected.to encrypt_attribute(:linkedin) }
    it { is_expected.to encrypt_attribute(:description) }

    it "has a default public slug" do
      individual = FactoryBot.create(:individual, public_slug: nil)

      expect(individual.public_slug).to match ShortKey.format_regex
    end

    describe "picture field" do
      it "should not be valid if picture is a heif" do
        file_path = Rails.root.join("spec", "support", "assets", "profile.heif")
        subject.picture.attach(io: File.open(file_path), filename: "profile.heif")
        subject.save

        expect(subject.errors[:picture]).to eq(["ta photo doit être au format jpg, jpeg ou png"])
      end

      it "should be valid if picture is a jpg" do
        file_path = Rails.root.join("spec", "support", "assets", "picture-profile.jpg")
        subject.picture.attach(io: File.open(file_path), filename: "profile.jpg")
        subject.save

        expect(subject.errors["picture"]).to be_empty
      end
    end

    describe "date_of_birth" do
      it "can't be later than current year" do
        invalid_individual = FactoryBot.build(:individual, date_of_birth: Date.today + 1)

        expect(invalid_individual).not_to be_valid
      end

      it "can't be earlier than 120 years from now" do
        invalid_individual = FactoryBot.build(:individual, date_of_birth: Date.today - 121.years)

        expect(invalid_individual).not_to be_valid
      end

      it "can be between today and 120 years earlier" do
        valid_individual = FactoryBot.build(:individual, date_of_birth: "14/04/1989")

        expect(valid_individual).to be_valid
      end

      it "can be nil" do
        valid_individual = FactoryBot.build(:individual)

        expect(valid_individual).to be_valid
      end
    end
  end

  it "#to_param generate a url using the individual's first and last name" do
    individual = FactoryBot.create(:individual, first_name: "Jane Junior", last_name: "Doe")

    expect(individual.to_param).to eq("#{individual.public_slug}-jane-junior-doe")
  end

  describe "#shareholder?" do
    it "returns true when individual has completed individual shares purchase" do
      individual = FactoryBot.create(:individual)
      FactoryBot.create(:shares_purchase, status: "completed", individual: individual)

      expect(individual.shareholder?).to be true
    end

    it "returns false when individual has only shares purchase by company" do
      individual = FactoryBot.create(:individual)
      FactoryBot.create(:shares_purchase, :from_company, status: "completed", individual: individual)

      expect(individual.shareholder?).to be false
    end

    it "returns false when individual does not have shareholder role" do
      individual = FactoryBot.create(:individual)
      FactoryBot.create(:shares_purchase, status: "pending", individual: individual)

      expect(individual.shareholder?).to be false
    end
  end

  describe "country" do
    it "is normalized and validated" do
      individual = FactoryBot.build(:individual)

      individual.country = nil
      expect(individual).to be_valid

      individual.country = "France"
      expect(individual).to be_valid
      expect(individual.country).to eq "FRA"

      individual.country = "Spain"
      expect(individual).to be_valid
      expect(individual.country).to eq "ESP"

      individual.country = "Espagne"
      expect(individual).to be_valid
      expect(individual.country).to eq "ESP"

      individual.country = "Espana"
      expect(individual).to be_valid
      expect(individual.country).to eq "ESP"

      individual.country = "fr"
      expect(individual).to be_valid
      expect(individual.country).to eq "FRA"

      individual.country = "CA"
      expect(individual).to be_valid
      expect(individual.country).to eq "CAN"

      individual.country = "ABC"
      expect(individual).to be_valid # normalize country passes country to nil when country is not found
      expect(individual.country).to be nil
    end
  end

  describe "attributes trimming" do
    it "trims required attributes" do
      FactoryBot.create(
        :individual,
        first_name: "Jane ",
        last_name: " Doe ",
        email: "jane@email.com ",
        linkedin: " https://some-url.com ",
        current_job: "Some job ",
        description: " A nice description",
        reasons_to_join: " Because... "
      )

      individual = Individual.last
      expect(individual.first_name).to eq("Jane")
      expect(individual.last_name).to eq("Doe")
      expect(individual.email).to eq("jane@email.com")
      expect(individual.linkedin).to eq("https://some-url.com")
      expect(individual.current_job).to eq("Some job")
      expect(individual.description).to eq("A nice description")
      expect(individual.reasons_to_join).to eq("Because...")
    end

    it "returns an empty string if attribute is blank" do
      FactoryBot.create(
        :individual,
        linkedin: "   "
      )

      expect(Individual.last.linkedin).to eq("")
    end

    it "leaves nil if attribute is nil" do
      FactoryBot.create(
        :individual,
        linkedin: nil
      )

      expect(Individual.last.linkedin).to be nil
    end

    it "trims trailing new line" do
      FactoryBot.create(
        :individual,
        linkedin: "https://some-url.com\n"
      )

      expect(Individual.last.linkedin).to eq("https://some-url.com")
    end

    it "trims tabs" do
      FactoryBot.create(
        :individual,
        linkedin: "https://some-url.com\t\t"
      )

      expect(Individual.last.linkedin).to eq("https://some-url.com")
    end
  end

  describe "attributes titleizing" do
    it "titleizes required attributes" do
      FactoryBot.create(
        :individual,
        first_name: "jane junior",
        last_name: "doe"
      )

      expect(Individual.last.first_name).to eq("Jane Junior")
      expect(Individual.last.last_name).to eq("Doe")
    end

    it "keeps hyphens between words" do
      FactoryBot.create(
        :individual,
        last_name: "doe-doe"
      )

      expect(Individual.last.last_name).to eq("Doe-Doe")
    end

    it "keeps accented characters" do
      FactoryBot.create(
        :individual,
        last_name: "doé"
      )

      expect(Individual.last.last_name).to eq("Doé")
    end
  end

  describe "origin setter override" do
    it "adds given origin to the existing ones if it is not already in the list" do
      individual = FactoryBot.create(:individual, origin: "facebook")
      expect(individual.origin).to eq(["facebook"])

      individual.update(origin: "linkedin")
      expect(individual.origin).to eq(["facebook", "linkedin"])

      individual.update(origin: "facebook")
      expect(individual.origin).to eq(["facebook", "linkedin"])
    end
  end

  describe "#geocodable_address" do
    it "returns nil if both city and country are blank" do
      FactoryBot.create(:individual, city: nil, country: " ")

      expect(Individual.last.geocodable_address).to be nil
    end

    it "returns the country only if no city is present" do
      FactoryBot.create(:individual, city: nil, country: "FRA")

      expect(Individual.last.geocodable_address).to eq("France")
    end

    it "returns the city only if no country is present" do
      FactoryBot.create(:individual, city: "Le Havre", country: nil)

      expect(Individual.last.geocodable_address).to eq("Le Havre")
    end

    it "returns city and country if both are present" do
      FactoryBot.create(:individual, city: "Lyon", country: "France")

      expect(Individual.last.geocodable_address).to eq("Lyon, France")
    end
  end

  describe "geolocation" do
    it "should not use precise address to geocode as latitude and longitude are not crypted" do
      # WARNING !!!
      # if this spec changes someday to take into account precise address in geolocation we must encrypt latitude
      # and longitude again
      individual = FactoryBot.create(:individual)

      individual.update(city: "Lyon", address: "10 rue Dumenge")

      expect(Individual.last.latitude).to eq(45.7484600)
      expect(Individual.last.longitude).to eq(4.8467100)
      expect(Individual.last.latitude).not_to eq(45.7766643)
      expect(Individual.last.longitude).not_to eq(4.83437)
    end

    it "geocodes when adding an address" do
      individual = FactoryBot.create(:individual)

      individual.update(city: "Lyon")

      expect(Individual.last.latitude).to eq(45.7484600)
      expect(Individual.last.longitude).to eq(4.8467100)
    end

    it "geocodes when changing the address" do
      individual = FactoryBot.create(:individual, city: "Lyon")

      individual.update(city: "Paris")

      expect(Individual.last.latitude).to eq(48.8534100)
      expect(Individual.last.longitude).to eq(2.3488000)
    end

    it "lets coordinates empty if geocoding failed" do
      individual = FactoryBot.create(:individual, longitude: 48.8534100, latitude: 2.3488000)

      individual.update(city: "Le Havre")
      expect(Individual.last.latitude).to be nil
      expect(Individual.last.longitude).to be nil
    end

    it "adds the country if only the city is present" do
      FactoryBot.create(:individual, city: "Lyon", country: nil)

      expect(Individual.last.country).to eq("FRA")
    end
  end

  describe "set_department_number callback" do
    it "sets department_number by taking first 2 character of zip_code if country is France" do
      individual = FactoryBot.create(:individual, country: "France", zip_code: "73600")

      expect(individual.reload.department_number).to eq("73")
    end

    it "does not set department number if country is different than France" do
      individual = FactoryBot.create(:individual, country: "England", zip_code: "73600")

      expect(individual.department_number).to be nil
    end
  end

  describe "reset_coordinates callback" do
    it "resets latitude and longitude to 0 if the city is changed" do
      individual = FactoryBot.create(:individual, city: "Lyon")

      individual.update(city: "Le Havre")

      expect(Individual.last.latitude).to be nil
      expect(Individual.last.longitude).to be nil
    end

    it "resets latitude and longitude to 0 if the country is changed" do
      individual = FactoryBot.create(:individual, city: "Lyon", country: "France")

      individual.update(country: "Belgique")

      expect(Individual.last.latitude).to be nil
      expect(Individual.last.longitude).to be nil
    end

    it "does not reset latitude and longitude to 0 if neither the city nor the country will change" do
      individual = FactoryBot.create(:individual, city: "Lyon")

      individual.update(first_name: "Michel")

      expect(Individual.last.latitude).not_to be nil
      expect(Individual.last.longitude).not_to be nil
    end
  end

  describe "notify_zapier_of_email_changed callback" do
    before(:each) do
      @zapier_notifier = double
      allow(@zapier_notifier).to receive(:notify_individual_email_changed).and_return("")
      allow(ZapierNotifier).to receive(:new).and_return(@zapier_notifier)
      @individual = FactoryBot.create(:individual, email: "old@email.com")
    end

    it "should notify zapier when email has changed" do
      @individual.update(email: "new@email.com")

      expect(@zapier_notifier).to have_received(:notify_individual_email_changed).with(@individual, "old@email.com")
    end

    it "should not notify zapier when email has not changed" do
      @individual.update(first_name: "Sasha")

      expect(@zapier_notifier).not_to have_received(:notify_individual_email_changed)
    end
  end

  describe "queue_locale_detector_job callback" do
    it "queues locale_detector_job if reasons_to_join is modified" do
      individual = FactoryBot.create(:individual)

      individual.update(reasons_to_join: "Who runs the world ? Girls !!")

      expect(IndividualLocaleDetectorJob).to have_received(:perform_later).with(individual.id)
    end

    it "does not queues locale_detector_job if reasons_to_join is not modified" do
      FactoryBot.create(:individual, reasons_to_join: nil)

      expect(IndividualLocaleDetectorJob).not_to have_received(:perform_later)
    end
  end

  describe "notify_new_shareholder" do
    it "creates notification if individual agreed to be displayed and is shareholder" do
      individual = FactoryBot.create(:individual)
      FactoryBot.create(:shares_purchase, status: "completed", individual: individual)

      expect {
        individual.notify_new_shareholder
      }.to change { Notification.count }.by 1
      expect(Notification.last.subject).to eq(Individual.last)
    end

    it "does not create notification if is_displayed is false" do
      individual = FactoryBot.create(:individual, is_displayed: false)

      expect {
        individual.notify_new_shareholder
      }.not_to change { Notification.count }
    end

    it "does not create notification if individual does not have shareholder role" do
      individual = FactoryBot.create(:individual, is_displayed: true)

      expect {
        individual.notify_new_shareholder
      }.not_to change { Notification.count }
    end
  end

  describe "remove_notifications callback" do
    it "destroys all notifications related to the individual if they does not want to be displayed anymore" do
      individual = FactoryBot.create(:individual)
      Notification.create(subject: individual)
      expect(individual.notifications.count).to eq(1)

      individual.update(is_displayed: false)

      expect(individual.notifications.count).to eq(0)
    end

    it "does nothing if user wants to be displayed again" do
      individual = FactoryBot.create(:individual, is_displayed: false)
      Notification.create(subject: individual)

      expect {
        individual.update(is_displayed: true)
      }.not_to change { Notification.count }
    end
  end

  describe "send_id_card_received_email callback" do
    it "enqueues sending job of id card received email if id_card_received_passed_to_true" do
      individual = FactoryBot.create(:individual)

      individual.update(id_card_received: true)

      expect(SendIdCardReceivedEmailJob).to have_received(:perform_later).with(individual.id)
    end

    it "does nothing if id_card_received change to false" do
      individual = FactoryBot.create(:individual, id_card_received: true)
      RSpec::Mocks.space.proxy_for(SendIdCardReceivedEmailJob).reset
      allow(SendIdCardReceivedEmailJob).to receive(:perform_later).and_return("")

      individual.update(id_card_received: false)

      expect(SendIdCardReceivedEmailJob).not_to have_received(:perform_later)
    end

    it "does nothing if id_card_received is not changed" do
      individual = FactoryBot.create(:individual)

      individual.update(first_name: "Mala")

      expect(SendIdCardReceivedEmailJob).not_to have_received(:perform_later)
    end
  end

  describe "destruction" do
    it "cannot be destroyed" do
      individual = create(:individual)
      expect { individual.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
    end
  end

  describe "shareholders_since" do
    it "handles people who bought shares after the date" do
      date = DateTime.now + 2.months

      Timecop.freeze(date + 1.second) do
        share = FactoryBot.create(:shares_purchase, status: :completed)

        expect(Individual.shareholders_since(date)).to eq [share.individual]
      end
    end

    it "handles people who BECAME shareholders after the date" do
      date = DateTime.now + 2.months

      individual = FactoryBot.create(:individual)
      expect(Individual.shareholders_since(date)).to eq []

      Timecop.freeze(date + 1.second) do
        share = FactoryBot.create(:shares_purchase, individual: individual, status: :pending)
        expect(Individual.shareholders_since(date)).to eq []

        share.update!(status: :completed)
        expect(Individual.shareholders_since(date)).to eq [individual]
      end
    end

    it "ignores people who were already shareholders before the date" do
      date = DateTime.now + 2.months

      individual = FactoryBot.create(:individual)
      FactoryBot.create(:shares_purchase, individual: individual, status: :completed)
      expect(Individual.shareholders_since(date)).to eq []

      Timecop.freeze(date + 1.second) do
        FactoryBot.create(:shares_purchase, individual: individual, status: :completed)
        expect(Individual.shareholders_since(date)).to eq []
      end
    end
  end
end
