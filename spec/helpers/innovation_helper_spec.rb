require "rails_helper"

describe InnovationHelper do
  describe "#innovation_tag" do
    it "should return nil when innovation status is 'received'" do
      innovation = FactoryBot.build(:innovation, status: "received")

      expect(innovation_tag_and_color(innovation)[:tag]).to be nil
      expect(innovation_tag_and_color(innovation)[:color]).to eq("grey")
    end

    it "should return star translation when innovation status is 'star'" do
      innovation = FactoryBot.build(:innovation, status: "star")

      expect(innovation_tag_and_color(innovation)[:tag]).to eq("Etoile")
      expect(innovation_tag_and_color(innovation)[:color]).to eq("rainforest600")
    end

    it "should return being_evaluated tag when expected" do
      FactoryBot.create(
        :episode, number: 4, season_number: 1, started_at: Date.today - 1.months, finished_at: Date.today + 1.month
      )
      innovation = FactoryBot.build(:innovation, status: "submitted_to_evaluations", selection_period: "S01E04")

      expect(innovation_tag_and_color(innovation)[:tag]).to eq("En cours d'évaluation")
      expect(innovation_tag_and_color(innovation)[:color]).to eq("lagoon500")
    end

    it "should return evaluated tag when expected" do
      innovation = FactoryBot.build(:innovation, status: "submitted_to_evaluations", selection_period: "S01E03")

      expect(innovation_tag_and_color(innovation)[:tag]).to eq("Evaluée")
      expect(innovation_tag_and_color(innovation)[:color]).to eq("lagoon100")
    end

    it "should return 'selected' tag in every other cases" do
      innovation = FactoryBot.build(:innovation, status: "submitted_to_scientific_comity")
      expect(innovation_tag_and_color(innovation)[:tag]).to eq("Sélectionnée")
      expect(innovation_tag_and_color(innovation)[:color]).to eq("rainforest400")

      innovation = FactoryBot.build(:innovation, status: "submitted_to_economical_tests")
      expect(innovation_tag_and_color(innovation)[:tag]).to eq("Sélectionnée")
      expect(innovation_tag_and_color(innovation)[:color]).to eq("rainforest400")

      innovation = FactoryBot.build(:innovation, status: "submitted_to_general_assembly")
      expect(innovation_tag_and_color(innovation)[:tag]).to eq("Sélectionnée")
      expect(innovation_tag_and_color(innovation)[:color]).to eq("rainforest400")
    end
  end

  describe "#should_display_rating?" do
    it "should return false when status is 'received'" do
      innovation = FactoryBot.build(:innovation, status: "received")

      expect(should_display_rating?(innovation)).to be false
    end

    describe "when status is 'submitted_to_evaluations'" do
      it "should return true when all conditions are met" do
        FactoryBot.create(
          :episode, number: 4, season_number: 1, started_at: Date.today - 1.months, finished_at: Date.today + 1.month
        )
        innovation = FactoryBot.build(:innovation,
          status: "submitted_to_evaluations", rating: 4.5, selection_period: "S01E03")

        expect(should_display_rating?(innovation)).to be true
      end

      it "should return false when rating is not present" do
        innovation = FactoryBot.build(:innovation, rating: nil)

        expect(should_display_rating?(innovation)).to be false
      end

      it "should return false when rating is under 0.25" do
        innovation = FactoryBot.build(:innovation, rating: 0.24)

        expect(should_display_rating?(innovation)).to be false
      end

      it "should return false when innovation is still being evaluated even if rating is already present" do
        FactoryBot.create(
          :episode, number: 4, season_number: 1, started_at: Date.today - 1.months, finished_at: Date.today + 1.month
        )
        innovation = FactoryBot.build(:innovation,
          status: "submitted_to_evaluations",
          selection_period: "S01E04",
          rating: 4.5)

        expect(should_display_rating?(innovation)).to be false
      end
    end

    it "should return true when status is 'submitted_to_scientific_comity'" do
      innovation = FactoryBot.build(:innovation, status: "submitted_to_scientific_comity", rating: 4.5)

      expect(should_display_rating?(innovation)).to be true
    end
  end

  describe "#remove_filter" do
    it "should remove the given lever from parameters" do
      params = {
        status: "star",
        search: "some search",
        filters: {
          domains: ["1", "2"],
          levers: ["1", "2", "3"]
        }
      }

      expected_params = {
        status: "star",
        search: "some search",
        filters: {
          domains: ["1", "2"],
          levers: ["1", "3"]
        }
      }

      expect(remove_filter(params, :levers, 2)).to eq(expected_params)
    end

    it "should remove the given domain from parameters" do
      params = {
        status: "star",
        search: "some search",
        filters: {
          domains: ["1", "2"],
          levers: ["1", "2", "3"]
        }
      }

      expected_params = {
        status: "star",
        search: "some search",
        filters: {
          domains: ["2"],
          levers: ["1", "2", "3"]
        }
      }

      expect(remove_filter(params, :domains, 1)).to eq(expected_params)
    end
  end

  describe "#change_status" do
    it "should replace the status in parameters" do
      params = {
        status: "star",
        search: "some search",
        filters: {
          domains: ["1", "2"],
          levers: ["1", "2", "3"]
        }
      }

      expected_params = {
        status: "submitted_to_scientific_comity",
        search: "some search",
        filters: {
          domains: ["1", "2"],
          levers: ["1", "2", "3"]
        }
      }

      expect(change_status(params, "submitted_to_scientific_comity")).to eq(expected_params)
    end
  end

  describe "#filter_display_name" do
    it "displays the code of episodes" do
      episode = FactoryBot.create(:episode, number: 1, season_number: 0)

      expect(filter_display_name(episode, "episodes")).to eq("S00E01")
    end

    it "displays the name of action domaines" do
      action_domain = FactoryBot.create(:action_domain, name: "Some name")

      expect(filter_display_name(action_domain, "action_domains")).to eq("Some name")
    end

    it "displays the name of action lever" do
      action_lever = FactoryBot.create(:action_lever, name: "Some name")

      expect(filter_display_name(action_lever, "action_levers")).to eq("Some name")
    end
  end

  describe "#key_figure_display" do
    it "should return nil when funded innovation attribute is not present" do
      funded_innovation = FactoryBot.build(:funded_innovation)

      expect(key_figure_display(funded_innovation.company_created_at)).to be nil
    end

    it "should return date in long format when attribute is a date" do
      funded_innovation = FactoryBot.build(:funded_innovation)

      expect(key_figure_display(funded_innovation.funded_at)).to eq(l(funded_innovation.funded_at, format: :long))
    end

    it "should return formatted number with currency when attribute is an integer" do
      funded_innovation = FactoryBot.build(:funded_innovation)

      expect(key_figure_display(funded_innovation.amount_invested)).to eq(
        number_to_currency(funded_innovation.amount_invested, locale: params[:locale], precision: 0, unit: "€")
      )
    end
  end
end
