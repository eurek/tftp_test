require "rails_helper"

RSpec.describe I18n::Backend::ActiveRecord, type: :model do
  before(:all) do
    I18n.backend = I18n::Backend::ActiveRecord.new
  end

  after(:all) do
    I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n::Backend::Simple.new)
  end

  before(:each) do
    Translation.destroy_all
  end

  def i18n_backend
    if I18n.backend.is_a?(I18n::Backend::Chain)
      return I18n.backend.backends.find { |b| b.is_a?(I18n::Backend::ActiveRecord) }
    end

    I18n.backend
  end

  describe "initialization" do
    it "is initially uninitialized" do
      expect(i18n_backend.initialized?).to eq false

      i18n_backend.init_translations
      expect(i18n_backend.initialized?).to eq true

      i18n_backend.reload!
      expect(i18n_backend.initialized?).to eq false

      i18n_backend.init_translations
      expect(i18n_backend.initialized?).to eq true
    end

    it "translations is initialized with do_init argument" do
      Translation.create(key: "foo.bar", value_i18n: {en: "bar"})
      i18n_backend.reload!
      expect(i18n_backend.initialized?).to eq false

      expected_hash = {en: {foo: {bar: "bar"}}}
      expect(i18n_backend.send(:translations, do_init: true)).to eq expected_hash
      expect(i18n_backend.initialized?).to eq true
    end
  end

  describe "helper methods" do
    it "expand_keys" do
      expect(i18n_backend.send(:expand_keys, :'foo.bar.baz')).to eq ["foo", "foo.bar", "foo.bar.baz"]
    end

    it "conflicting_keys" do
      expect(i18n_backend.send(:conflicting_keys, :'foo.bar.baz')).to eq ["foo", "foo.bar"]
    end
  end

  describe "store_translations" do
    it "can store translations" do
      i18n_backend.store_translations(:en, foo: {baz: "baz"})
      expect(Translation.count).to eq 1
      expect(Translation.first.key).to eq "foo.baz"
      expect(Translation.first.value_i18n).to eq("en" => "baz")
    end

    it "can store translations with keys that are translations containing special chars" do
      i18n_backend.store_translations(:es, "Pagina's": "Pagina's")
      expect(I18n.t("Pagina's", locale: :es)).to eq "Pagina's"
    end

    it "prevents ambiguous keys" do
      i18n_backend.store_translations(:en, foo: "foo")
      i18n_backend.store_translations(:en, foo: {bar: "bar"})
      i18n_backend.store_translations(:en, foo: {baz: "baz"})

      expect(Translation.find_by_key("foo")).to eq nil
      expect(Translation.find_by_key("foo.bar")).not_to eq nil
      expect(Translation.find_by_key("foo.baz")).not_to eq nil

      expect(I18n.t("foo", locale: :en)).to eq(bar: "bar", baz: "baz")
    end

    it "prevents ambiguous keys (2)" do
      i18n_backend.store_translations(:en, foo: {bar: "bar"})
      i18n_backend.store_translations(:en, foo: {baz: "baz"})
      i18n_backend.store_translations(:en, foo: "foo")

      expect(Translation.find_by_key("foo.bar")).to eq nil
      expect(Translation.find_by_key("foo.baz")).to eq nil
      expect(Translation.find_by_key("foo")).not_to eq nil

      expect(I18n.t("foo", locale: :en)).to eq("foo")
    end

    it "updating a value for a locale doesnt effect the values in other locales for the same key" do
      expect(Translation.find_by_key("foo")&.value_i18n).to eq nil

      i18n_backend.store_translations(:en, foo: "foo")
      expect(Translation.find_by_key("foo")&.value_i18n).to eq("en" => "foo")

      i18n_backend.store_translations(:fr, foo: "le foo")
      expect(Translation.find_by_key("foo")&.value_i18n).to eq("en" => "foo", "fr" => "le foo")
    end

    it "can have an option to only create, never update" do
      i18n_backend.store_translations(:en, foo: "foo")
      expect(Translation.find_by_key("foo")&.value_i18n).to eq("en" => "foo")

      i18n_backend.store_translations(:en, {foo: "new foo"}, create_only: true)
      expect(Translation.find_by_key("foo")&.value_i18n).to eq("en" => "foo")

      i18n_backend.store_translations(:fr, {foo: "le foo"}, create_only: true)
      expect(Translation.find_by_key("foo")&.value_i18n).to eq("en" => "foo", "fr" => "le foo")
    end
  end

  describe "fetching data" do
    it "available_locales" do
      i18n_backend.store_translations(:en, foo: {bar: "bar"})
      i18n_backend.store_translations(:en, foo: {baz: "baz"})
      i18n_backend.store_translations(:fr, foo1: "foo")
      i18n_backend.store_translations(:fr, foo2: "foo")
      i18n_backend.store_translations(:es, foo3: "foo")

      expect(Translation.available_locales.sort).to eq ["en", "fr", "es"].sort
    end

    it "translations returns all translations" do
      Translation.create(key: "foo.bar", value_i18n: {en: "bar"})
      Translation.create(key: "foo.baz", value_i18n: {en: "baz"})
      i18n_backend.init_translations

      expected = {en: {foo: {bar: "bar", baz: "baz"}}}
      expect(i18n_backend.send(:translations)).to eq expected
      expect(i18n_backend.initialized?).to eq true
    end

    it "can fetch a stored translation" do
      i18n_backend.store_translations(:fr, foo: {bar: "bar"})
      expect(I18n.t("foo.bar")).to eq "bar"
    end

    it "returns all keys via ." do
      i18n_backend.store_translations(:en, foo: {bar: "bar"})
      i18n_backend.store_translations(:en, foo: {baz: "baz"})
      i18n_backend.store_translations(:fr, foo1: "foo")

      expect(I18n.t(".", locale: :en)).to eq(foo: {bar: "bar", baz: "baz"})
      expect(I18n.t(".", locale: :fr)).to eq(foo1: "foo")
    end

    it "can access keys with a trailing/leading period" do
      i18n_backend.store_translations(:fr, foo: {bar: "bar", baz: "baz"})
      expected = {bar: "bar", baz: "baz"}
      expect(I18n.t("foo")).to eq expected
      expect(I18n.t(".foo")).to eq expected
      expect(I18n.t("foo.")).to eq expected
      expect(I18n.t(".foo.")).to eq expected
      expect(I18n.t(".foo.")).to eq expected
    end

    it "handles returning all keys via . when there are no keys" do
      i18n_backend.reload!
      expect(I18n.t(".")).to eq "translation missing: fr.no key"
    end

    it "fetching subtree of translations" do
      data = {
        foo: {
          bar: {fizz: "buzz", spuz: "zazz"},
          baz: {fizz: "buzz"}
        }
      }

      i18n_backend.store_translations(:fr, data)
      expect(I18n.t("foo")).to eq data[:foo]
      expect(I18n.t("foo.bar")).to eq data[:foo][:bar]
    end
  end

  describe "caching" do
    it "caches its translations at init time" do
      i18n_backend.store_translations(:fr, foo: "foo")
      expect(I18n.t("foo")).to eq "foo"

      Translation.find_by_key("foo").update_columns(value_i18n: {fr: "updated"})
      expect(I18n.t("foo")).to eq "foo"

      i18n_backend.reload!
      expect(I18n.t("foo")).to eq "updated"
    end

    it "resets its cache after a store operation" do
      i18n_backend.store_translations(:fr, foo: "foo")
      expect(I18n.t("foo")).to eq "foo"

      Translation.find_by_key("foo").update_columns(value_i18n: {fr: "updated"})
      expect(I18n.t("foo")).to eq "foo"

      i18n_backend.store_translations(:fr, bar: "bar")
      expect(I18n.t("foo")).to eq "updated"
    end

    it "resets its cache after a Translation update" do
      i18n_backend.store_translations(:fr, foo: "foo")
      expect(I18n.t("foo")).to eq "foo"

      Translation.find_by_key("foo").update(value_i18n: {fr: "updated"})
      expect(I18n.t("foo")).to eq "updated"
    end
  end

  describe "chained with yaml files" do
    before(:each) do
      I18n.backend = I18n::Backend::Chain.new(I18n::Backend::ActiveRecord.new, I18n::Backend::Simple.new)
    end

    it "fallback to yaml files if the translation cant be found" do
      create(:translation, key: "common.login", value_i18n: {en: "Login", it: "Connessione"})
      expect(I18n.t("common.login", locale: :en, fallback: false)).to eq "Login"
      expect(I18n.t("common.login", locale: :it, fallback: false)).to eq "Connessione"
      expect(I18n.t("common.login", locale: :fr, fallback: false)).to eq "Connexion"
      expect(I18n.t("common.login", locale: :es, fallback: false)).to eq(
        "translation missing: es.common.login"
      )
    end
  end
end
