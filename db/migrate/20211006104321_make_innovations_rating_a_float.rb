class MakeInnovationsRatingAFloat < ActiveRecord::Migration[6.1]
  def self.up
    change_column :innovations, :rating, :float
  end

  def self.down
    change_column :innovations, :rating, :integer
  end
end
