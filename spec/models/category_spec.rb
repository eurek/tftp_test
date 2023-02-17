require "rails_helper"

describe Category, type: :model do
  it { is_expected.to have_many(:contents).dependent(:nullify) }
  it { is_expected.to have_many(:tags).dependent(:destroy) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:title).allow_nil }
  it { is_expected.to allow_value("foo-bar-2").for(:slug) }
  it { is_expected.not_to allow_value("foo_bar").for(:slug) }
end
