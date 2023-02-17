class AddTimestampsToIndividuals < ActiveRecord::Migration[6.1]
  def change
    add_timestamps :individuals, default: Time.zone.now
    change_column_default :individuals, :created_at, nil
    change_column_default :individuals, :updated_at, nil
  end
end
