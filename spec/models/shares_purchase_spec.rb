require "rails_helper"

RSpec.describe SharesPurchase, type: :model do
  include Rails.application.routes.url_helpers
  include RSpec::Matchers

  subject { FactoryBot.build(:shares_purchase) }
  it { is_expected.to validate_presence_of(:amount) }
  it { is_expected.to validate_presence_of(:typeform_answer_uid) }
  it { is_expected.to validate_presence_of(:form_completed_at) }
  it { is_expected.to validate_presence_of(:payment_method) }
  it { is_expected.to validate_presence_of(:status) }
  it { is_expected.to belong_to(:individual) }
  it { is_expected.to belong_to(:company).optional }
  it { is_expected.to validate_uniqueness_of(:external_uid).allow_nil }
  it { is_expected.to validate_uniqueness_of(:transfer_reference).allow_nil }
  it { is_expected.to validate_uniqueness_of(:zoho_sign_request_id).allow_nil }
  it { is_expected.to validate_uniqueness_of(:typeform_answer_uid) }
  it {
    is_expected.to define_enum_for(:payment_method).with_values(
      card_stripe: "card_stripe",
      transfer_ce: "transfer_ce",
      debit_gocardless: "debit_gocardless",
      gift_coupon: "gift_coupon",
      secondary_market: "secondary_market"
    ).with_suffix(:payment_method).backed_by_column_of_type(:string)
  }
  it {
    is_expected.to define_enum_for(:status).with_values(
      pending: "pending",
      canceled: "canceled",
      completed: "completed",
      sold: "sold"
    ).with_suffix(:status).backed_by_column_of_type(:string)
  }
  it {
    is_expected.to define_enum_for(:payment_status).with_values(
      pending: "pending",
      refunded: "refunded",
      paid: "paid"
    ).with_suffix(:payment).backed_by_column_of_type(:string)
  }

  describe "subscription_bulletin field" do
    it "should be a valid pdf" do
      subject.subscription_bulletin.attach(
        io: File.open("spec/support/assets/resume.png"),
        filename: "resume.png"
      )
      subject.save
      expect(subject.errors[:subscription_bulletin]).to eq(["Subscription bulletin doit être au format pdf"])

      subject.subscription_bulletin.attach(
        io: File.open("spec/support/assets/bulletin.pdf"),
        filename: "bulletin.pdf"
      )
      subject.save
      expect(subject.errors[:subscription_bulletin]).to be_empty
    end
  end

  describe "subscription_bulletin_certificate field" do
    it "should be empty if there is no subscription bulletin" do
      subject.subscription_bulletin_certificate.attach(
        io: File.open("spec/support/assets/bulletin.pdf"),
        filename: "bulletin.pdf"
      )
      subject.save
      expect(subject.errors[:subscription_bulletin_certificate]).to eq(["doit être vide"])
    end

    it "should be a valid pdf" do
      subject.subscription_bulletin.attach(
        io: File.open("spec/support/assets/bulletin.pdf"),
        filename: "bulletin.pdf"
      )
      subject.subscription_bulletin_certificate.attach(
        io: File.open("spec/support/assets/resume.png"),
        filename: "resume.png"
      )
      subject.save
      message = "Subscription bulletin certificate doit être au format pdf"
      expect(subject.errors[:subscription_bulletin_certificate]).to eq([message])

      subject.subscription_bulletin_certificate.attach(
        io: File.open("spec/support/assets/bulletin.pdf"),
        filename: "bulletin.pdf"
      )
      subject.save
      expect(subject.errors[:subscription_bulletin_certificate]).to be_empty
    end
  end

  describe "model scope" do
    it "calculate the total amount raised of all shares purchases through scope" do
      FactoryBot.create(:shares_purchase, amount: 200, status: "completed")
      FactoryBot.create(:shares_purchase, amount: 300, status: "completed")
      FactoryBot.create(:shares_purchase, amount: 300, status: "pending")

      expect(SharesPurchase.total_raised).to eq(500)
    end

    it "completed returns only shares purchases with completed status" do
      FactoryBot.create(:shares_purchase, status: "pending")
      FactoryBot.create(:shares_purchase, status: "canceled")
      FactoryBot.create(:shares_purchase, status: "sold")
      purchase = FactoryBot.create(:shares_purchase, status: "completed", amount: 300)

      expect(SharesPurchase.completed).to eq([purchase])
    end

    it "by_company returns all shares purchases made by company or associated to a company" do
      purchase = FactoryBot.create(:shares_purchase, :from_company)
      FactoryBot.create(:shares_purchase, amount: 300)

      expect(SharesPurchase.by_company).to eq([purchase])
    end

    it "by_individual returns all shares purchases made by individual or not associated to a company" do
      FactoryBot.create(:shares_purchase, :from_company)
      purchase = FactoryBot.create(:shares_purchase, amount: 300)

      expect(SharesPurchase.by_individual).to eq([purchase])
    end
  end

  describe "without_subscription_bulletin" do
    it "returns only shares purchases without subscription bulletins" do
      shares_purchase = create(:shares_purchase)
      expect(SharesPurchase.without_subscription_bulletin).to include shares_purchase

      shares_purchase.subscription_bulletin.attach(
        io: File.open("spec/support/assets/bulletin.pdf"),
        filename: "bulletin.pdf"
      )
      expect(SharesPurchase.without_subscription_bulletin).not_to include shares_purchase
    end
  end

  describe "day top" do
    it "returns today's biggest shares purchase" do
      not_displayed_individual = FactoryBot.create(:individual, is_displayed: false)
      displayed_individual = FactoryBot.create(:individual)
      shares_purchase = FactoryBot.create(:shares_purchase, amount: 10000, individual: not_displayed_individual)
      FactoryBot.create(:shares_purchase, amount: 5000, individual: displayed_individual)
      FactoryBot.create(:shares_purchase, amount: 20000, individual: displayed_individual,
        completed_at: 2.days.ago)

      expect(SharesPurchase.day_top).to eq(shares_purchase)
    end
  end

  describe "week top" do
    it "returns this week's biggest shares purchase" do
      not_displayed_individual = FactoryBot.create(:individual, is_displayed: false)
      displayed_individual = FactoryBot.create(:individual)
      shares_purchase = FactoryBot.create(
        :shares_purchase,
        amount: 7000,
        individual: not_displayed_individual,
        completed_at: Date.today
      )
      FactoryBot.create(
        :shares_purchase, amount: 5000, individual: displayed_individual, completed_at: Date.today
      )
      FactoryBot.create(
        :shares_purchase, amount: 10000, individual: displayed_individual, completed_at: 1.week.ago
      )

      expect(SharesPurchase.week_top).to eq(shares_purchase)
    end
  end

  describe "year top" do
    it "returns this year's biggest shares purchase" do
      allow(Date).to receive(:today).and_return Date.new(2020, 2, 3)

      not_displayed_individual = FactoryBot.create(:individual, is_displayed: false)
      displayed_individual = FactoryBot.create(:individual)
      shares_purchase = FactoryBot.create(
        :shares_purchase,
        amount: 7000,
        individual: not_displayed_individual,
        completed_at: Date.new(2020, 1, 3)
      )
      FactoryBot.create(
        :shares_purchase, amount: 5000, individual: displayed_individual, completed_at: Date.new(2020, 1, 6)
      )
      FactoryBot.create(
        :shares_purchase, amount: 10000, individual: displayed_individual, completed_at: Date.new(2019, 2, 3)
      )

      expect(SharesPurchase.year_top).to eq(shares_purchase)
    end
  end

  describe "month top" do
    it "returns this month's biggest shares purchase" do
      allow(Date).to receive(:today).and_return Date.new(2020, 2, 16)

      FactoryBot.create(
        :shares_purchase, amount: 10000, completed_at: Date.new(2020, 1, 6)
      )
      FactoryBot.create(
        :shares_purchase, amount: 5000, completed_at: Date.new(2020, 2, 3)
      )

      month_top = FactoryBot.create(
        :shares_purchase, amount: 8000, completed_at: Date.new(2020, 2, 12)
      )

      expect(SharesPurchase.month_top).to eq(month_top)
    end
  end

  describe "all time top" do
    it "returns the all time biggest shares purchase" do
      allow(Date).to receive(:today).and_return Date.new(2020, 2, 16)

      all_time_top = FactoryBot.create(
        :shares_purchase, amount: 10000, completed_at: Date.new(2018, 1, 6)
      )

      FactoryBot.create(
        :shares_purchase, amount: 5000, completed_at: Date.new(2020, 2, 3)
      )

      FactoryBot.create(
        :shares_purchase, amount: 8000, completed_at: Date.new(2020, 2, 12)
      )

      expect(SharesPurchase.all_time_top).to eq(all_time_top)
    end
  end

  describe "after_completed_purchase callback" do
    it "enqueue AfterCompleteSharesPurchaseJob if status is completed" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      shares_purchase.update(status: "completed")

      expect(AfterCompleteSharesPurchaseJob).to have_received(:perform_later).with(shares_purchase.id)
    end

    it "does nothing if status is not completed" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      shares_purchase.update(status: "canceled")

      expect(AfterCompleteSharesPurchaseJob).not_to have_received(:perform_later)
    end
  end

  describe "set_transfer_reference callback" do
    it "auto-increment transfer_reference for a transfer purchase from last record with transfer_reference" do
      puts FactoryBot.create(:shares_purchase, payment_method: "transfer_ce", transfer_reference: "74541")
      transfer_purchase = FactoryBot.create(:shares_purchase)

      transfer_purchase.update(payment_method: "transfer_ce")

      expect(transfer_purchase.reload.transfer_reference).to eq("74542")
    end

    it "does nothing if payment_method is not 'transfer_ce'" do
      stripe_purchase = FactoryBot.create(:shares_purchase, payment_method: "card_stripe")

      stripe_purchase.update(payment_method: "card_stripe")

      expect(stripe_purchase.transfer_reference).to be nil
    end
  end

  describe "mark_as_paid callback" do
    it "sets paid_at to now if payment status is updated to paid" do
      stubbed_time = DateTime.new(2021, 5, 13, 10, 0)
      allow(DateTime).to receive(:now).and_return(stubbed_time)
      shares_purchase = FactoryBot.create(:shares_purchase)

      shares_purchase.update(payment_status: :paid)

      expect(shares_purchase.reload.paid_at).to eq(stubbed_time)
    end

    it "does not set paid_at if payment status is not modified" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      shares_purchase.update(amount: 300)

      expect(shares_purchase.reload.paid_at).to be nil
    end

    it "does not set paid_at nor complete purchase if payment status is different than paid" do
      shares_purchase = FactoryBot.create(:shares_purchase, completed_at: nil)

      shares_purchase.update(payment_status: "refunded")

      expect(shares_purchase.reload.paid_at).to be nil
      expect(shares_purchase.reload.status).to eq("pending")
      expect(shares_purchase.reload.completed_at).to be nil
    end

    it "completes purchase if payment status changed to paid and subscription bulletin was already attached" do
      stubbed_time = DateTime.new(2021, 5, 13, 10, 0)
      allow(DateTime).to receive(:now).and_return(stubbed_time)
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin, payment_status: :pending,
        completed_at: nil)

      shares_purchase.update(payment_status: "paid")

      expect(shares_purchase.reload.status).to eq("completed")
      expect(shares_purchase.reload.completed_at).to eq(stubbed_time)
    end

    it "doesn't complete purchase if no subscription bulletin is attached" do
      shares_purchase = FactoryBot.create(:shares_purchase, payment_status: :pending, completed_at: nil)

      shares_purchase.update(payment_status: "paid")

      expect(shares_purchase.reload.status).to eq("pending")
      expect(shares_purchase.reload.completed_at).to be nil
    end
  end

  describe "file_uploaded callback" do
    it "request sending of email with bank details if transfer payment is pending" do
      stub = stub_request(:post, "https://hooks.zapier.com/hooks/catch/5761965/bn5ksml/")
        .to_return({status: 200, body: "{}"})
      shares_purchase = FactoryBot.create(:shares_purchase, payment_status: :pending, payment_method: "transfer_ce",
        completed_at: nil)

      shares_purchase.subscription_bulletin.attach(
        io: File.open(Rails.root.join("spec/support/assets/bulletin.pdf")),
        filename: "bulletin.pdf"
      )
      shares_purchase.subscription_bulletin_certificate.attach(
        io: File.open(Rails.root.join("spec/support/assets/certificate.pdf")),
        filename: "bulletin.pdf"
      )

      expect(stub).to have_been_requested.once
    end

    it "completes purchase if payment is received already" do
      stubbed_time = DateTime.new(2021, 5, 13, 10, 0)
      allow(DateTime).to receive(:now).and_return(stubbed_time)
      shares_purchase = FactoryBot.create(:shares_purchase, payment_status: :paid, payment_method: "card_stripe",
        completed_at: nil)

      shares_purchase.subscription_bulletin.attach(
        io: File.open(Rails.root.join("spec/support/assets/bulletin.pdf")),
        filename: "bulletin.pdf"
      )

      expect(shares_purchase.reload.status).to eq("completed")
      expect(shares_purchase.reload.completed_at).to eq(stubbed_time)
    end

    it "doesn't try to complete purchase again when uploading certificate" do
      stubbed_time = DateTime.new(2021, 5, 13, 10, 0)
      allow(DateTime).to receive(:now).and_return(stubbed_time)
      shares_purchase = FactoryBot.create(:shares_purchase, payment_status: :paid, payment_method: :card_stripe,
        completed_at: nil)

      shares_purchase.subscription_bulletin.attach(
        io: File.open(Rails.root.join("spec/support/assets/bulletin.pdf")),
        filename: "bulletin.pdf"
      )

      expect(shares_purchase.reload.status).to eq("completed")
      expect(shares_purchase.reload.completed_at).to eq(stubbed_time)

      new_stubbed_time = DateTime.new(2021, 5, 13, 11, 0)
      allow(DateTime).to receive(:now).and_return(stubbed_time)

      shares_purchase.subscription_bulletin_certificate.attach(
        io: File.open(Rails.root.join("spec/support/assets/certificate.pdf")),
        filename: "bulletin.pdf"
      )

      expect(shares_purchase.reload.status).to eq("completed")
      expect(shares_purchase.reload.completed_at).not_to eq(new_stubbed_time)
      expect(shares_purchase.reload.completed_at).to eq(stubbed_time)
    end
  end

  describe "cascading callbacks" do
    it "file_uploaded completes purchase if payment is received already" do
      stubbed_time = DateTime.new(2021, 5, 13, 10, 0)
      allow(DateTime).to receive(:now).and_return(stubbed_time)
      shares_purchase = FactoryBot.create(:shares_purchase, payment_status: :paid, payment_method: "card_stripe",
        completed_at: nil)

      shares_purchase.subscription_bulletin.attach(
        io: File.open(Rails.root.join("spec/support/assets/bulletin.pdf")),
        filename: "bulletin.pdf"
      )
      shares_purchase.subscription_bulletin_certificate.attach(
        io: File.open(Rails.root.join("spec/support/assets/certificate.pdf")),
        filename: "bulletin.pdf"
      )

      expect(shares_purchase.reload.status).to eq("completed")
      expect(shares_purchase.reload.completed_at).to eq(stubbed_time)
      expect(AfterCompleteSharesPurchaseJob).to have_received(:perform_later).with(shares_purchase.id)
    end

    it "mark_as_paid completes purchase if subscription bulletin is already attached" do
      stubbed_time = DateTime.new(2021, 5, 13, 10, 0)
      allow(DateTime).to receive(:now).and_return(stubbed_time)
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin, payment_status: :pending,
        completed_at: nil)

      shares_purchase.update(payment_status: "paid")

      expect(shares_purchase.reload.status).to eq("completed")
      expect(shares_purchase.reload.completed_at).to eq(stubbed_time)
      expect(AfterCompleteSharesPurchaseJob).to have_received(:perform_later).with(shares_purchase.id)
    end
  end

  describe "detect shares purchases callback" do
    it "calls the callback after create" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      expect(DetectSharesPurchaseDuplicatesJob).to have_received(:perform_later).with(shares_purchase.id)
    end

    it "doesn't call the callback after an update" do
      shares_purchase = FactoryBot.create(:shares_purchase)

      shares_purchase.update(form_completed_at: Time.now)

      expect(DetectSharesPurchaseDuplicatesJob).to have_received(:perform_later).once
    end
  end

  describe "destruction" do
    it "cannot be destroyed" do
      shares_purchase = FactoryBot.create(:shares_purchase)
      expect { shares_purchase.destroy! }.to raise_error ActiveRecord::RecordNotDestroyed
    end
  end
end
