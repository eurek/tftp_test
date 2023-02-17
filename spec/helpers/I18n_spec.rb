require "rails_helper"

describe I18n do
  it "should not be possible to create a translation without a key" do
    new_translation = Translation.new(key: nil, value: "bar")

    expect(new_translation.save).to be false
  end

  it "should allow to save in database a simple translation" do
    Translation.create(key: "foo", value: "bar")

    I18n.backend.reload!

    expect(I18n.t("foo")).to eq("bar")
  end

  it "should allow to save in database a translation with nested key" do
    Translation.create(key: "foo.bar", value: "lorem ipsum")

    I18n.backend.reload!

    expect(I18n.t("foo.bar")).to eq("lorem ipsum")
  end

  it "should allow to save in database an array of translations" do
    Translation.create(
      key: "foo.bar",
      value: [{key1: "lorem", key2: "ipsum"}, {key1: "blob", key2: "flop"}]
    )

    I18n.backend.reload!

    expect(I18n.t("foo.bar").first[:key1]).to eq("lorem")
    expect(I18n.t("foo.bar").first[:key2]).to eq("ipsum")
    expect(I18n.t("foo.bar").second[:key1]).to eq("blob")
    expect(I18n.t("foo.bar").second[:key2]).to eq("flop")
  end

  it "should allow to save in database an string with interpolation" do
    Translation.create(key: "foo.bar", value: "Hello %{name}")

    I18n.backend.reload!

    expect(I18n.t("foo.bar", name: "Sasha")).to eq("Hello Sasha")
  end

  it "should not allow to save in database a translation with the same key" do
    Translation.create(key: "foo", value: "lorem")

    duplicate_translation = Translation.create(key: "foo", value: "ipsum")

    expect(duplicate_translation.errors.messages).to eq({key: ["est déjà utilisé(e)"]})
    expect(Translation.count).not_to eq(2)
  end
end
