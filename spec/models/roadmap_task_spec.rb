require "rails_helper"

RSpec.describe RoadmapTask, type: :model do
  subject { FactoryBot.build(:roadmap_task) }

  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:duration_type) }
  it { is_expected.to validate_presence_of(:category) }
  it {
    is_expected.to define_enum_for(:duration_type).with_values(
      short: "short",
      medium: "medium",
      long: "long"
    ).with_suffix(:term).backed_by_column_of_type(:string)
  }
  it {
    is_expected.to define_enum_for(:status).with_values(
      to_do: "to_do",
      in_progress: "in_progress",
      done: "done"
    ).with_prefix(:status).backed_by_column_of_type(:string)
  }
  it {
    is_expected.to define_enum_for(:category).with_values(
      community: "community",
      structure: "structure",
      funding: "funding",
      enterprise_creation: "enterprise_creation"
    ).with_suffix(:category).backed_by_column_of_type(:string)
  }

  describe "default values" do
    it "should have done_at set to nil" do
      expect(subject.done_at).to eq(nil)
    end

    it "should have status set to to_do" do
      expect(subject.status).to eq("to_do")
    end
  end

  describe "have and belong to many relationship" do
    let(:rt_a) { FactoryBot.create(:roadmap_task) }
    let(:rt_b) { FactoryBot.create(:roadmap_task) }
    let(:rt_c) { FactoryBot.create(:roadmap_task) }

    it "can have many other roadmap_tasks association" do
      rt_a.prerequisite_tasks = [rt_b, rt_c]

      expect(rt_a.reload.prerequisite_tasks.length).to eq(2)
      expect(rt_b.dependent_task_ids).to eq([rt_a.id])
    end

    it "can exists without any children" do
      expect(rt_c.prerequisite_tasks.length).to eq(0)
    end

    it "should destroy associated prerequisite when destroying a task which is a prerequisite of another task" do
      rt_a.prerequisite_tasks = [rt_b]

      rt_b.destroy

      expect(Prerequisite.count).to eq(0)
      expect(rt_a.reload.prerequisite_tasks).to eq([])
    end

    it "should destroy associated prerequisite when destroying a task which has prerequisites" do
      rt_a.prerequisite_tasks = [rt_b]

      rt_a.destroy

      expect(Prerequisite.count).to eq(0)
      expect(rt_b.reload.dependent_tasks).to eq([])
    end
  end

  it "scope done should include task with done_at not nil and tasks with status done" do
    to_do = FactoryBot.create(:roadmap_task)
    done = FactoryBot.create(:roadmap_task, status: :done)
    done_today = FactoryBot.create(:roadmap_task, done_at: Date.today)

    done_task_ids = RoadmapTask.done.pluck(:id)

    expect(done_task_ids).to include(done.id)
    expect(done_task_ids).to include(done_today.id)
    expect(done_task_ids).not_to include(to_do.id)
  end

  it "scope not_done should only include task with done_at nil and status other than done" do
    to_do = FactoryBot.create(:roadmap_task)
    done = FactoryBot.create(:roadmap_task, status: :done)
    done_today = FactoryBot.create(:roadmap_task, done_at: Date.today)

    not_done_task_ids = RoadmapTask.not_done.pluck(:id)

    expect(not_done_task_ids).not_to include(done.id)
    expect(not_done_task_ids). not_to include(done_today.id)
    expect(not_done_task_ids).to include(to_do.id)
  end
end
