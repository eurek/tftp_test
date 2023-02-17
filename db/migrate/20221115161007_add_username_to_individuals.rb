class AddUsernameToIndividuals < ActiveRecord::Migration[6.1]
  def change
    add_column :individuals, :username, :string
    remove_column :individuals, :origin, :text
    add_column :individuals, :origin, :text, array: true, default: []
  end
end
