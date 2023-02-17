require "rails_helper"

RSpec.describe DatabaseContentModifier, type: :model do
  let(:prev_domains) do
    %w[
      https://www.time-planet.com
      http://www.time-planet.com
      time-planet.com
      https://staging-time-planet.herokuapp.com
      localhost:3000
    ]
  end

  describe "self.match_url_to_environment_columns" do
    it "returns only valid columns" do
      expected = [:external_uid, :name_i18n, :description_i18n]
      expect(Role.modifiable_columns).to eq expected
    end
  end

  describe "self.rewrite_value_for_environment" do
    def execute(value)
      lambda = lambda do |string_value|
        prev_domains.each do |other_domain|
          string_value = string_value.gsub(other_domain, "www.example.com")
        end
        string_value
      end
      ApplicationRecord.rewrite_value(value, lambda)
    end

    it "handles strings" do
      expect(execute("http://www.time-planet.com/fr")).to eq "www.example.com/fr"
    end

    it "handles hashes" do
      expect(execute({fr: "http://www.time-planet.com/fr"})).to eq(fr: "www.example.com/fr")
    end

    it "handles nil" do
      expect(execute(nil)).to eq(nil)
      expect(execute({fr: nil})).to eq(fr: nil)
    end

    it "raises if the type is not handled" do
      expect { execute(12.03) }.to raise_exception ArgumentError
    end
  end

  describe "match_url_to_environment" do
    it "goes through all expected columns and fixes its content if needed" do
      role = FactoryBot.create(
        :role,
        # Not supposed to contain this kind of text but it's for the test
        external_uid: "Title for https://staging-time-planet.herokuapp.com/fr/my-page",
        name_i18n: {
          en: "We should replace the following url: https://www.time-planet.com/en",
          fr: "time-planet.com/fr",
          it: "localhost:3000/it"
        }
      )
      role.match_url_to_environment("http://example.com", prev_domains)

      # updated
      expect(role.external_uid).to eq "Title for http://example.com/fr/my-page"
      expect(role.name_i18n).to eq({
        "en" => "We should replace the following url: http://example.com/en",
        "fr" => "http://example.com/fr",
        "it" => "http://example.com/it"
      })
    end
  end

  describe "replace_content" do
    it "goes through all expected columns and fixes its content if needed" do
      role = FactoryBot.create(
        :role,
        # Not supposed to contain this kind of text but it's for the test
        external_uid: "time for the planet",
        name_i18n: {
          en: "We should replace the following string: Time for the Planet",
          fr: "TIME FOR THE PLANET",
          it: "Time For The Planet"
        }
      )
      role.replace_content(/time for the planet/i, "Time for the Planet<span class='brand'>®</span>")

      # updated
      expect(role.external_uid).to eq "Time for the Planet<span class='brand'>®</span>"
      expect(role.name_i18n).to eq({
        "en" => "We should replace the following string: Time for the Planet<span class='brand'>®</span>",
        "fr" => "Time for the Planet<span class='brand'>®</span>",
        "it" => "Time for the Planet<span class='brand'>®</span>"
      })
    end
  end
end
