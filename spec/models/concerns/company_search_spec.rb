require "rails_helper"

RSpec.describe CompanySearch, type: :model do
  before(:each) do
    @company1 = FactoryBot.create(:company, name: "test", address: "in paris")
    @company2 = FactoryBot.create(:company, name: "test bis", address: "in paris")
  end

  it "can search companies by name and address" do
    expect(Company.full_text_search("TEST")).to eq [@company1, @company2]
    expect(Company.full_text_search("Pâri")).to eq [@company1, @company2]
    expect(Company.full_text_search("Lyon")).to eq []
  end

  it "can search companies by name only while ignoring accents" do
    expect(Company.name_search("TEST")).to eq [@company1, @company2]
    expect(Company.name_search("têst")).to eq [@company1, @company2]
    expect(Company.name_search("TES")).to eq [@company1, @company2]
    expect(Company.name_search("in paris")).to eq []
  end

  it "can search companies by exact name while ignoring accents" do
    expect(Company.exact_name_search("TEST")).to eq [@company1]
    expect(Company.exact_name_search("têst")).to eq [@company1]
    expect(Company.exact_name_search("TES")).to eq []
    expect(Company.exact_name_search("in paris")).to eq []
  end
end
