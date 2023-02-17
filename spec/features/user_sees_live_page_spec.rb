require "rails_helper"

feature "user sees live page" do
  let(:memory_store) { ActiveSupport::Cache.lookup_store(:memory_store) }
  let(:cache) { Rails.cache }

  scenario "successfully" do
    visit live_path({locale: :fr})

    expect(page).to have_content("En direct de Time")
  end

  scenario "successfully and can load more notifications", js: true do
    innovation = FactoryBot.create(:innovation)
    20.times do |index|
      innovation.update(evaluations_amount: index + 1)
    end
    visit live_path({locale: :fr})
    expect(page).to have_css(".Notification", count: 10)

    find_link(class: ["Button", "Button--secondaryLagoon", "Button--iconLeft"]).click

    expect(page).to have_css(".Notification", count: 20)
  end

  scenario "and cache statistics" do
    allow(Rails).to receive(:cache).and_return(memory_store)
    cache.clear

    expect(cache.exist?("live_statistics")).to be(false)

    visit live_path({locale: :fr})

    expect(cache.exist?("live_statistics")).to be(true)

    # expires after 10 minutes
    Timecop.freeze(Time.now + 11.minutes) do
      expect(cache.exist?("live_statistics")).to be(false)

      visit live_path({locale: :fr})

      expect(cache.exist?("live_statistics")).to be(true)
    end
  end
end
