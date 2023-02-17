class AddValueToBadges < ActiveRecord::Migration[6.1]
  def change
    add_column :badges, :value, :string
  end
end
