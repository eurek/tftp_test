class AddDecryptedCoordinatesToIndividuals < ActiveRecord::Migration[6.1]
  def change
    add_column :individuals, :decrypted_latitude, :float
    add_column :individuals, :decrypted_longitude, :float
  end
end
