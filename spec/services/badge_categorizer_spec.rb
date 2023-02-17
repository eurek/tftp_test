require "rails_helper"

describe BadgeCategorizer do
  it "groups badges by category" do
    individual = FactoryBot.create(:individual)
    badge1 = FactoryBot.create(:badge, category: "year")
    badge2 = FactoryBot.create(:badge, category: "financial")
    badge3 = FactoryBot.create(:badge, category: "financial")
    individual.badges << [badge1, badge2, badge3]

    categorized_badges = BadgeCategorizer.new(Badge.all).categorize("light")

    expect(categorized_badges).to eq({"year" => [badge1], "financial" => [badge2, badge3]})
  end

  it "eager loads picture attachments with requested mode" do
    individual = FactoryBot.create(:individual)
    badge = FactoryBot.create(:badge, :with_picture_light, category: "year")
    individual.badges << badge

    categorized_badges = BadgeCategorizer.new(Badge.all).categorize("light")

    expect(categorized_badges["year"].first.association_cached?(:picture_light_attachment)). to be true
    expect(categorized_badges["year"].first.picture_light_attachment.association_cached?(:blob)). to be true
  end

  it "adds accomplishments_count to each badges" do
    individual = FactoryBot.create(:individual)
    badge = FactoryBot.create(:badge, :with_picture_light, category: "year")
    individual.badges << badge

    categorized_badges = BadgeCategorizer.new(Badge.all).categorize("light")

    expect(categorized_badges["year"].first.accomplishments_count).to eq(1)
  end
end
