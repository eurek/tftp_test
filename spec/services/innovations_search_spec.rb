require "rails_helper"

describe InnovationsSearch do
  before(:each) do
    @sailing_boat = FactoryBot.create(
      :innovation,
      name: "Sailing Boat",
      short_description_i18n: {en: "A groundbreaking transportation system that uses wind"},
      status: "submitted_to_general_assembly",
      submitted_at: 10.day.ago
    )
    @warm_sweater = FactoryBot.create(
      :innovation,
      name: "Warm Sweater",
      short_description_i18n: {en: "An innovative insulation system for individuals"},
      problem_solved_i18n: {en: "Heating houses uses a lot of energy, espcially in winter"},
      potential_clients_i18n: {en: "Everyone, except maybe naturist people."},
      differentiating_elements_i18n: {en: "Not only the insulation is efficient, but it can be stylish."},
      founders: ["Riri", "Fifi", "Loulou"],
      status: "received",
      submitted_at: 1.day.ago
    )
    @laudry_rack = FactoryBot.create(
      :innovation,
      name: "Laundry Rack",
      solution_explained_i18n: {
        en: "The laundry is placed on a wire. With the help of sun and wind, the laundry dries"
      },
      status: "submitted_to_general_assembly",
      submitted_at: 30.day.ago
    )
  end

  it "orders results by most recent" do
    expect(InnovationsSearch.search).to eq([@warm_sweater, @sailing_boat, @laudry_rack])
  end

  it "filters by status" do
    expect(InnovationsSearch.search(status: "submitted_to_general_assembly")).to eq([@sailing_boat, @laudry_rack])
  end

  it "searches in name" do
    expect(InnovationsSearch.search(term: "sweater")).to eq([@warm_sweater])
  end

  it "searches in short description" do
    expect(InnovationsSearch.search(term: "transportation")).to eq([@sailing_boat])
  end

  it "searches in founders" do
    expect(InnovationsSearch.search(term: "Loulou")).to eq([@warm_sweater])
  end

  it "searches in problem solved" do
    expect(InnovationsSearch.search(term: "energy")).to eq([@warm_sweater])
  end

  it "searches in solution explained" do
    expect(InnovationsSearch.search(term: "wire")).to eq([@laudry_rack])
  end

  it "searches in potential clients" do
    expect(InnovationsSearch.search(term: "everyone")).to eq([@warm_sweater])
  end

  it "searches in differenciating elements" do
    expect(InnovationsSearch.search(term: "stylish")).to eq([@warm_sweater])
  end

  it "filters by action lever" do
    action_lever = FactoryBot.create(:action_lever)

    action_lever.innovations << @laudry_rack
    action_lever.innovations << @sailing_boat

    expect(InnovationsSearch.search(levers: [action_lever.id])).to eq([@sailing_boat, @laudry_rack])
  end

  it "filters by domain" do
    action_domain = FactoryBot.create(:action_domain)

    action_domain.innovations << @laudry_rack
    action_domain.innovations << @warm_sweater

    expect(InnovationsSearch.search(domains: [action_domain.id])).to eq([@warm_sweater, @laudry_rack])
  end

  it "filters by submission episode" do
    episode = FactoryBot.create(:episode, started_at: 12.days.ago, finished_at: 2.days.ago)

    episode.submitted_innovations << @sailing_boat

    expect(InnovationsSearch.search(episodes: [episode.id])).to eq([@sailing_boat])
  end
end
