class ReplaceEncryptedCoordinatesOfIndividuals < ActiveRecord::Migration[6.1]
  def change
    remove_column :individuals, :latitude_ciphertext, :text
    remove_column :individuals, :longitude_ciphertext, :text
    rename_column :individuals, :decrypted_latitude, :latitude
    rename_column :individuals, :decrypted_longitude, :longitude
  end
end
