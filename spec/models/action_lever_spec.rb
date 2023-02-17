require "rails_helper"

RSpec.describe ActionLever, type: :model do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to have_many(:innovations).dependent(:nullify) }
end
