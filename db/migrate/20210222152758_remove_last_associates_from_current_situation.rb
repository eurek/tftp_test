class RemoveLastAssociatesFromCurrentSituation < ActiveRecord::Migration[5.2]
  def change
    3.times do |index|
      remove_column :current_situations, "last_associate_name_#{index + 1}".to_sym
      remove_column :current_situations, "last_associate_shares_#{index + 1}".to_sym
      remove_column :current_situations, "last_associate_date_#{index + 1}".to_sym
    end
  end
end
