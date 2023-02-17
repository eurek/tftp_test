require "rails_helper"

describe CurrentSituation, type: :model do
  it { is_expected.to validate_presence_of(:total_shareholders) }
end
