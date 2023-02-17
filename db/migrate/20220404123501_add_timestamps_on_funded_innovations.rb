class AddTimestampsOnFundedInnovations < ActiveRecord::Migration[6.1]
  def change
    add_timestamps :funded_innovations, default: Time.zone.now
    change_column_default :funded_innovations, :created_at, nil
    change_column_default :funded_innovations, :updated_at, nil
  end
end
