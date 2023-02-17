require "rails_helper"

describe CommunicationLocaleSetter do
  it "set locale to individual's last shares_purchase typeform_language" do
    individual = FactoryBot.create(:individual)
    FactoryBot.create(:shares_purchase, typeform_language: :es, individual: individual)

    CommunicationLocaleSetter.new(individual).set

    expect(I18n.locale).to eq(:es)
  end

  it "set locale to individual's communication_language if typeform_language is not included in available locales" do
    individual = FactoryBot.create(:individual, communication_language: :en)
    FactoryBot.create(:shares_purchase, typeform_language: :all, individual: individual)

    CommunicationLocaleSetter.new(individual).set

    expect(I18n.locale).to eq(:en)
  end

  it "set locale to :fr if neither of communication_language nor typeform_language is included in available locales" do
    individual = FactoryBot.create(:individual, communication_language: nil)
    FactoryBot.create(:shares_purchase, typeform_language: :all, individual: individual)

    CommunicationLocaleSetter.new(individual).set

    expect(I18n.locale).to eq(:fr)
  end
end
