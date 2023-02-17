require "rails_helper"

describe RoadmapTaskHelper do
  describe "#status_display" do
    it "precises when the task has been finished when status is done and done_at is present" do
      task = FactoryBot.create(:roadmap_task, status: :done, done_at: Date.parse("2020-08-31"))

      expect(helper.status_display(task)).to eq("Terminée le 31/08/2020")
    end

    it "indicates that it is done when status is done but done_at is not present" do
      task = FactoryBot.create(:roadmap_task, status: :done)

      expect(helper.status_display(task)).to eq("Terminée")
    end

    it "indicates in progress status translation" do
      task = FactoryBot.create(:roadmap_task, status: :in_progress)

      expect(helper.status_display(task)).to eq("En cours")
    end

    it "indicates to_do status translation" do
      task = FactoryBot.create(:roadmap_task, status: :to_do)

      expect(helper.status_display(task)).to eq("A faire")
    end
  end

  describe "#task_color" do
    it "returns lagoon when category is community" do
      task = FactoryBot.create(:roadmap_task, category: "community")

      expect(helper.task_color(task)).to eq("lagoon")
    end

    it "returns purple when category is structure" do
      task = FactoryBot.create(:roadmap_task, category: "structure")

      expect(helper.task_color(task)).to eq("purple")
    end

    it "returns red when category is funding" do
      task = FactoryBot.create(:roadmap_task, category: "funding")

      expect(helper.task_color(task)).to eq("red")
    end

    it "returns green when category is enterprise_creation" do
      task = FactoryBot.create(:roadmap_task, category: "enterprise_creation")

      expect(helper.task_color(task)).to eq("green")
    end
  end
end
