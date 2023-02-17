require "rails_helper"

feature "user sees roadmap page" do
  scenario "succesffuly" do
    visit roadmap_tasks_path({locale: :fr})

    expect(page).to have_content("Notre plan d'action")
  end

  scenario "should see last done task" do
    FactoryBot.create(:roadmap_task, done_at: Date.yesterday, status: "done")
    medium_done_after = FactoryBot.create(:roadmap_task, done_at: Date.today, status: "done", duration_type: "medium")

    visit roadmap_tasks_path({locale: :fr})

    expect(find(".CurrentSituation-lastDone", text: medium_done_after.title)).to be_present
  end

  scenario "tasks should be sorted by duration_type" do
    short_term_task = FactoryBot.create(:roadmap_task)
    medium_term_task = FactoryBot.create(:roadmap_task, duration_type: "medium")
    long_term_task = FactoryBot.create(:roadmap_task, duration_type: "long")

    visit roadmap_tasks_path({locale: :fr})

    expect(find("h3", text: short_term_task.title)).to appear_before(find("h3", text: medium_term_task.title))
    expect(find("h3", text: medium_term_task.title)).to appear_before(find("h3", text: long_term_task.title))
  end

  scenario "done tasks should be sorted by done_at" do
    short_done_before = FactoryBot.create(:roadmap_task, done_at: Date.yesterday, status: "done")
    short_done_after = FactoryBot.create(:roadmap_task, done_at: Date.today, status: "done")
    medium_done_before = FactoryBot.create(:roadmap_task,
      done_at: Date.yesterday, status: "done", duration_type: "medium")
    medium_done_after = FactoryBot.create(:roadmap_task, done_at: Date.today, status: "done", duration_type: "medium")
    long_done_before = FactoryBot.create(:roadmap_task, done_at: Date.yesterday, status: "done", duration_type: "long")
    long_done_after = FactoryBot.create(:roadmap_task, done_at: Date.today, status: "done", duration_type: "long")

    visit roadmap_tasks_path({locale: :fr})

    expect(find("h3", text: short_done_before.title)).to appear_before(find("h3", text: short_done_after.title))
    expect(find("h3", text: medium_done_before.title)).to appear_before(find("h3", text: medium_done_after.title))
    expect(find("h3", text: long_done_before.title)).to appear_before(find("h3", text: long_done_after.title))
  end

  scenario "to do tasks should be sorted by position" do
    short_to_do_before = FactoryBot.create(:roadmap_task, position: 1)
    short_to_do_after = FactoryBot.create(:roadmap_task, position: 2)
    medium_to_do_before = FactoryBot.create(:roadmap_task, position: 1)
    medium_to_do_after = FactoryBot.create(:roadmap_task, position: 2)
    long_to_do_before = FactoryBot.create(:roadmap_task, position: 1)
    long_to_do_after = FactoryBot.create(:roadmap_task, position: 1)

    visit roadmap_tasks_path({locale: :fr})

    expect(find("h3", text: short_to_do_before.title)).to appear_before(find("h3", text: short_to_do_after.title))
    expect(find("h3", text: medium_to_do_before.title)).to appear_before(find("h3", text: medium_to_do_after.title))
    expect(find("h3", text: long_to_do_before.title)).to appear_before(find("h3", text: long_to_do_after.title))
  end

  scenario "and can see task details", js: true do
    task = FactoryBot.create(:roadmap_task)

    visit roadmap_tasks_path({locale: :fr})
    find("li", text: task.title).click

    expect(page).to have_content(task.text)
  end

  scenario "and can see task details even when text is nil", js: true do
    task = FactoryBot.create(:roadmap_task, text: nil)

    visit roadmap_tasks_path({locale: :fr})
    find("li", text: task.title).click

    expect(find(".Details", text: task.title)).to be_present
  end
end
