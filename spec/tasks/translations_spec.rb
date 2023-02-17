require "rails_helper"

describe "translations rake tasks" do
  it "load_yml_files" do
    former_key = "former_key"
    Translation.create(key: former_key, value: "bla bla")
    key_present_in_db = "common.slogan"
    Translation.create(key: key_present_in_db, value: "value present in db")

    Rake::Task["translations:load_yml_files"].invoke

    expect(Translation.find_by(key: former_key)).to be nil
    expect(Translation.find_by(key: key_present_in_db).value).to eq("value present in db")
  end
end
