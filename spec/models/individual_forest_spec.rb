require "rails_helper"

RSpec.describe "Forest::Individual", type: :model do
  describe "schema" do
    before(:each) do
      # save schema file
      @schema_content = File.read(ForestLiana::Bootstrapper::SCHEMA_FILENAME)

      # let's ask ForestAdmin to rewrite its file
      allow(Rails).to receive(:env) { "development".inquiry }
      allow(Rails.application.config.action_controller).to receive(:perform_caching) { true }
      ForestLiana::Bootstrapper.new
    end

    after(:each) do
      File.write(ForestLiana::Bootstrapper::SCHEMA_FILENAME, @schema_content)
    end

    it "excludes ciphertext and blind index columns" do
      # then make sure the encrypted columns have not been added to it
      schema = JSON.parse(File.read(ForestLiana::Bootstrapper::SCHEMA_FILENAME))
      schema["collections"].each do |collection|
        collection["fields"].each do |field|
          expect(field["field"]).not_to end_with("_ciphertext")
          expect(field["field"]).not_to end_with("_bidx")
        end
      end
    end

    it "includes smart fields for each encrypted field" do
      # then make sure the encrypted columns have not been added to it
      schema = JSON.parse(File.read(ForestLiana::Bootstrapper::SCHEMA_FILENAME))
      schema["collections"].each do |collection|
        next if collection["name"].include?("__")

        collection["name"].constantize.try(:lockbox_attributes)&.each do |attr, config|
          field = collection["fields"].find { |f| f["field"] == attr.to_s }
          blind_index = collection["name"].capitalize.constantize.blind_indexes.key?(field["field"].to_sym)
          expect(field).not_to be_nil
          expect(field["type"]).to eq Forest::LOCKBOX_TYPES_CORRESPONDENCES[config[:type]]
          expect(field["is_read_only"]).to eq false
          expect(field["is_filterable"]).to eq blind_index
          expect(field["is_sortable"]).to eq false
          expect(field["is_virtual"]).to eq true
        end
      end
    end
  end
end
