require "rails_helper"

RSpec.describe AfterCompleteSharesPurchaseJob, type: :job do
  include Capybara::Email::DSL

  describe "#perform" do
    before(:each) do
      @stub = stub_request(:post, "https://hooks.zapier.com/hooks/catch/5761965/bn5k7qt/")
        .to_return({status: 200, body: "{}"})
    end

    it "requests sending of confirmation email and create notification if appropriate" do
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin,
        completed_at: DateTime.now, payment_method: :card_stripe, payment_status: :paid, status: :completed)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(Notification.count).to eq(1)
      expect(@stub).to have_been_requested.once
    end

    it "does not request sending of confirmation email if gocardless payment" do
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin,
        completed_at: nil, payment_method: :debit_gocardless, payment_status: :paid)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(@stub).not_to have_been_requested
      expect(Notification.count).to eq(1)
    end

    it "creates a user if it is the first completed shares purchase of individual" do
      individual = FactoryBot.create(:individual)
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin, individual: individual,
        status: :completed, payment_status: :paid)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(User.count).to eq(1)
      expect(User.last).to eq(shares_purchase.individual.user)
      expect(I18n.locale).to eq(:fr)
      expect(Devise.mailer.deliveries.count).to eq(1)
      open_email(individual.email)
      expect(current_email).to have_content("Bonjour #{individual.first_name},")
    end

    it "sets locale to send email in same language as typeform used to buy shares" do
      individual = FactoryBot.create(:individual)
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin, individual: individual,
        status: :completed, payment_status: :paid, typeform_language: :es)
      Translation.create(key: "devise.confirmations.email.hello", value_i18n: {es: "Hola"})

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(User.count).to eq(1)
      expect(User.last).to eq(shares_purchase.individual.user)
      expect(I18n.locale).to eq(:es)
      expect(Devise.mailer.deliveries.count).to eq(1)
      open_email(individual.email)
      expect(current_email).to have_content("Hola #{individual.first_name},")
    end

    it "creates a user even if individual has a previous canceled shares_purchase" do
      individual = FactoryBot.create(:individual)
      FactoryBot.create(:shares_purchase, individual: individual, status: :canceled)
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin, individual: individual,
        status: :completed, payment_status: :paid)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(User.count).to eq(1)
      expect(User.last).to eq(shares_purchase.individual.user)
      expect(Devise.mailer.deliveries.count).to eq(1)
      open_email(individual.email)
      expect(current_email).to have_content("Bonjour #{individual.first_name},")
    end

    it "set admin to shareholder company if appropriate" do
      individual = FactoryBot.create(:individual)
      company = FactoryBot.create(:company)
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin, individual: individual,
        company: company, status: :completed, payment_status: :paid)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(User.count).to eq(1)
      expect(User.last).to eq(shares_purchase.individual.user)
      expect(company.reload.admin).to eq(shares_purchase.individual.user)
    end

    it "resends confirmation instruction if user exists already but is still pending" do
      individual = FactoryBot.create(:individual)
      User.create(individual: individual, pending: true)
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin, individual: individual,
        status: :completed, payment_status: :paid)
      Devise.mailer.deliveries.clear

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(User.count).to eq(1)
      expect(Devise.mailer.deliveries.count).to eq(1)
      open_email(individual.email)
      expect(current_email).to have_content("Bonjour #{individual.first_name},")
    end

    it "doesn't create user if it's not first individual's first completed purchase (user destroyed his/her account)" do
      individual = FactoryBot.create(:individual)
      FactoryBot.create(:shares_purchase, individual: individual, status: "completed")
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin, individual: individual,
        status: :completed, payment_status: :paid)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(User.count).to eq(0)
      expect(Devise.mailer.deliveries.count).to eq(0)
    end

    it "does not create another user if individual already has a user" do
      user = FactoryBot.create(:user, pending: false)
      shares_purchase = FactoryBot.create(:shares_purchase, :with_subscription_bulletin, individual: user.individual,
        status: :completed, payment_status: :paid)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(User.count).to eq(1)
      expect(Devise.mailer.deliveries.count).to eq(0)
    end

    it "does nothing if shares_purchase is not completed" do
      shares_purchase = FactoryBot.create(:shares_purchase, status: :canceled)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(@stub).not_to have_been_requested
      expect(User.count).to eq(0)
      expect(Devise.mailer.deliveries.count).to eq(0)
      expect(Notification.count).to eq(0)
    end

    # below cases should not happen because
    it "does nothing if no subscription bulletin is attached" do
      shares_purchase = FactoryBot.create(:shares_purchase, payment_status: :paid, status: :completed)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(@stub).not_to have_been_requested
      expect(User.count).to eq(0)
      expect(Devise.mailer.deliveries.count).to eq(0)
      expect(Notification.count).to eq(0)
    end

    it "does nothing if purchase is not paid" do
      shares_purchase = FactoryBot.create(:shares_purchase, payment_status: :refunded, status: :completed)

      AfterCompleteSharesPurchaseJob.perform_now(shares_purchase.id)

      expect(@stub).not_to have_been_requested
      expect(User.count).to eq(0)
      expect(Devise.mailer.deliveries.count).to eq(0)
      expect(Notification.count).to eq(0)
    end
  end
end
