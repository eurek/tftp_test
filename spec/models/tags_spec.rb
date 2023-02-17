require "rails_helper"

describe Tag, type: :model do
  it { is_expected.to have_many(:contents) }
  it { is_expected.to belong_to(:category) }
  it { is_expected.to validate_presence_of(:slug) }
  it { is_expected.to validate_uniqueness_of(:slug) }
  it { is_expected.to allow_value("foo-bar-2").for(:slug) }
  it { is_expected.not_to allow_value("foo_bar").for(:slug) }
end
