require "rails_helper"

RSpec.describe RoleAttribution, type: :model do
  it { is_expected.to have_db_column(:entity_id).of_type(:integer) }
  it { is_expected.to have_db_column(:entity_type).of_type(:string) }
  it { is_expected.to belong_to(:role) }
  it { is_expected.to belong_to(:entity) }
  it { is_expected.to validate_inclusion_of(:entity_type).in_array(["Company", "Individual"]) }
end
