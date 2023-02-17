require "rails_helper"

describe ShareholdersSearch do
  before(:each) do
    @individual_a = FactoryBot.create(:individual, first_name: "Martine", last_name: "Cageot", is_displayed: true)
    @individual_b = FactoryBot.create(:individual, first_name: "George", last_name: "Cageot", is_displayed: true)
    @admin = FactoryBot.create(:user, individual: FactoryBot.create(:individual, is_displayed: false))
    @company_a = FactoryBot.create(:company, admin: @admin, name: "France TV", is_displayed: true)
    @company_b = FactoryBot.create(:company, admin: @admin, name: "France Television", is_displayed: true)
    @all_shareholders = [@company_b, @company_a, @individual_b, @individual_a]

    @badge_common = create(:badge)
    @badge_a = create(:badge)
    @badge_b = create(:badge)
    @individual_a.badges << @badge_a
    @individual_b.badges << @badge_b
    @company_a.badges << @badge_a
    @company_b.badges << @badge_b
    @individual_a.badges << @badge_common
    @individual_b.badges << @badge_common
    @company_a.badges << @badge_common
    @company_b.badges << @badge_common

    @role_common = create(:role)
    @role_a = create(:role)
    @role_b = create(:role)
    @individual_a.roles << @role_a
    @individual_b.roles << @role_b
    @company_a.roles << @role_a
    @company_b.roles << @role_b
    @individual_a.roles << @role_common
    @individual_b.roles << @role_common
    @company_a.roles << @role_common
    @company_b.roles << @role_common
  end

  it "has default search values and sorts by created_at" do
    expect(ShareholdersSearch.search_shareholders).to eq [@company_b, @company_a, @individual_b, @individual_a]
  end

  it "filters on company name and individual first and last name" do
    expect(ShareholdersSearch.search_shareholders(term: "FRANCE")).to eq [@company_b, @company_a]
    expect(ShareholdersSearch.search_shareholders(term: "TV")).to eq [@company_a]
    expect(ShareholdersSearch.search_shareholders(term: "MART")).to eq [@individual_a]
    expect(ShareholdersSearch.search_shareholders(term: "câgeot")).to eq [@individual_b, @individual_a]
  end

  it "ignores hidden shareholders" do
    @individual_a.update(is_displayed: false)
    @company_a.update(is_displayed: false)
    expect(ShareholdersSearch.search_shareholders(term: "france")).to eq [@company_b]
    expect(ShareholdersSearch.search_shareholders(term: "Cageot")).to eq [@individual_b]
  end

  it "shows companies that are not shareholders but have at least one employee" do
    @company_a.update(admin: nil, creator: @admin)
    expect(ShareholdersSearch.search_shareholders(term: "FRANCE")).to eq [@company_b, @company_a]
    expect(ShareholdersSearch.search_shareholders(term: "TV")).to eq [@company_a]
  end

  it "filters on badges" do
    expect(ShareholdersSearch.search_shareholders(badge_ids: [@badge_a.id])).to eq [@company_a, @individual_a]
    expect(ShareholdersSearch.search_shareholders(badge_ids: [@badge_b.id])).to eq [@company_b, @individual_b]
    expect(ShareholdersSearch.search_shareholders(badge_ids: [@badge_common.id])).to eq @all_shareholders
  end

  it "filters roles" do
    expect(ShareholdersSearch.search_shareholders(role_ids: [@role_a.id])).to eq [@company_a, @individual_a]
    expect(ShareholdersSearch.search_shareholders(role_ids: [@role_b.id])).to eq [@company_b, @individual_b]
    expect(ShareholdersSearch.search_shareholders(role_ids: [@role_common.id])).to eq @all_shareholders
  end

  it "filters on type" do
    expect(ShareholdersSearch.search_shareholders(types: [:individual])).to eq [@individual_b, @individual_a]
    expect(ShareholdersSearch.search_shareholders(types: [:company])).to eq [@company_b, @company_a]
    expect(ShareholdersSearch.search_shareholders(types: [:individual, :company])).to eq @all_shareholders
    expect(ShareholdersSearch.search_shareholders(types: [:other])).to eq []
  end

  it "supports pagination with page 2 limit 2" do
    result = ShareholdersSearch.search_shareholders(page: 2, limit: 2)
    expect(result).to eq [@individual_b, @individual_a]
    expect(result.limit_value).to eq 2
    expect(result.current_page).to eq 2
    expect(result.total_pages).to eq 2
    expect(result.total_accounts).to eq 4
  end

  it "supports pagination with page 1 limit 3" do
    result = ShareholdersSearch.search_shareholders(page: 1, limit: 3)
    expect(result).to eq [@company_b, @company_a, @individual_b]
    expect(result.limit_value).to eq 3
    expect(result.current_page).to eq 1
    expect(result.total_pages).to eq 2
    expect(result.total_accounts).to eq 4
  end

  it "supports pagination with page 1 limit 5 and display all shareholders" do
    result = ShareholdersSearch.search_shareholders(page: 1, limit: 5)
    expect(result).to eq @all_shareholders
    expect(result.limit_value).to eq 5
    expect(result.current_page).to eq 1
    expect(result.total_pages).to eq 1
    expect(result.total_accounts).to eq 4
  end

  it "supports pagination with page 1 and limit 2" do
    result = ShareholdersSearch.search_shareholders(page: 1, limit: 2)
    expect(result).to eq [@company_b, @company_a]
    expect(result.limit_value).to eq 2
    expect(result.current_page).to eq 1
    expect(result.total_pages).to eq 2
    expect(result.total_accounts).to eq 4
  end

  it "sorts shareholders with avatar first" do
    individual_with_avatar = FactoryBot.create(:individual, :with_picture, is_displayed: true)
    individual_without_avatar = FactoryBot.create(:individual, is_displayed: true)
    company_with_avatar = FactoryBot.create(:company, :with_logo, admin: @admin, is_displayed: true,)
    company_without_avatar = FactoryBot.create(:company, admin: @admin, is_displayed: true,)

    result = ShareholdersSearch.search_shareholders

    expect(result[0]).to eq company_with_avatar
    expect(result[1]).to eq individual_with_avatar
    expect(result[2]).to eq company_without_avatar
    expect(result[3]).to eq individual_without_avatar
  end
end
