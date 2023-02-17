require "rails_helper"

describe CallToAction, type: :model do
  it { is_expected.to have_many(:contents).dependent(:nullify) }
end
