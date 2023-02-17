require "rails_helper"

describe "String" do
  describe "#unaccent" do
    let(:accentuated_words) do
      {
        "Françoise d'Isaïe" => "Francoise d'Isaie",
        "Vær så god" => "Vaer sa god",
        "Cœur" => "Coeur",
        "Ʒʒ" => "Ʒʒ"
      }
    end
    it "removes accents" do
      accentuated_words.each do |given, expected|
        expect(given.unaccent).to eq expected
      end
    end

    let(:non_latin_words) do
      [
        "雙屬性集合之空間分群演算法-應用於地理資料",
        "مرحبا"
      ]
    end
    it "keeps non latin characters" do
      non_latin_words.each do |given|
        expect(given.unaccent).to eq given
      end
    end

    def postgres_unaccent(string)
      quoted_string = ActiveRecord::Base.connection.quote(string)
      ActiveRecord::Base.connection.select_one("SELECT unaccent(#{quoted_string})").values.first
    end
    it "mimicks PostgreSQL unaccent method" do
      (accentuated_words.keys + non_latin_words).each do |word|
        expect(word.unaccent).to eq postgres_unaccent(word)
      end
    end
  end

  describe "gsub_sql" do
    it "does a regex replace easily" do
      create(:company, address: "18, rue des Lapins\n93017 Mârcel, France")
      sql_field = "unaccent(lower(address))"
        .gsub_sql("\n", " ")
        .gsub_sql(",", "")
        .gsub_sql("  ", " ")

      expect(Company.pluck(Arel.sql(sql_field))).to eq ["18 rue des lapins 93017 marcel france"]
    end
  end
end
