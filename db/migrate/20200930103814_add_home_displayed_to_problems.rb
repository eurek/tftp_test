class AddHomeDisplayedToProblems < ActiveRecord::Migration[5.2]
  def change
    add_column :problems, :home_displayed, :boolean, default: false
  end
end
