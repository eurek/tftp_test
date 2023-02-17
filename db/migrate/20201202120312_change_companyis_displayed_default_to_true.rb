class ChangeCompanyisDisplayedDefaultToTrue < ActiveRecord::Migration[5.2]
  def change
    change_column_default :companies, :is_displayed, from: false, to: true
  end
end
