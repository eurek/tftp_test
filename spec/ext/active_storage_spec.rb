require "rails_helper"

describe "Active Storage" do
  describe "#attach_from_url" do
    it "successfully" do
      innovation = FactoryBot.create(:innovation)

      innovation.picture.attach_from_url("https://dummyimage.com/30x30/000/fff")

      expect(innovation.picture.attached?).to be true
    end

    it "attaches already existing blob if same file is already stored" do
      innovation_1 = FactoryBot.create(:innovation)
      innovation_1.picture.attach_from_url("https://dummyimage.com/30x30/000/fff")
      innovation_2 = FactoryBot.create(:innovation)

      innovation_2.picture.attach_from_url("https://dummyimage.com/30x30/000/fff")

      expect(innovation_2.picture.attached?).to be true
      expect(innovation_2.picture.blob.id).to eq(innovation_1.picture.blob.id)
    end
  end
end
