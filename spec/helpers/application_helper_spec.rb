require "rails_helper"

describe ApplicationHelper do
  describe "#get_host_without_www" do
    it "strips protocol" do
      expect(helper.get_host_without_www("https://mon-cdi.fr")).to eq("mon-cdi.fr")
    end

    it "strips protocol and subdomain" do
      expect(helper.get_host_without_www("https://www.mon-cdi.fr")).to eq("mon-cdi.fr")
    end

    it "strips path" do
      expect(helper.get_host_without_www("https://www.mon-cdi.fr/home")).to eq("mon-cdi.fr")
    end

    it "returns nil when url is blank" do
      expect(helper.get_host_without_www("")).to eq(nil)
    end

    it "returns nil when url is nil" do
      expect(helper.get_host_without_www(nil)).to eq(nil)
    end
  end

  describe "#is_a_buying_shares_path?" do
    it "returns true is the path is a buying shares path" do
      [
        helper.become_shareholder_path,
        helper.become_shareholder_company_path,
        helper.offer_shares_path,
        helper.offer_shares_company_path,
        helper.buy_shares_choice_path
      ].each do |path|
        expect(helper.is_a_buying_shares_path?(path)).to be true
      end
    end

    it "returns false otherwise" do
      expect(helper.is_a_buying_shares_path?(helper.root_path)).to be false
    end
  end
end
