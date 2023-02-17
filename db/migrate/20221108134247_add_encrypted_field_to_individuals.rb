class AddEncryptedFieldToIndividuals < ActiveRecord::Migration[6.1]
  def change
    add_column :individuals, :first_name_ciphertext, :text
    add_column :individuals, :first_name_bidx, :string
    add_column :individuals, :last_name_ciphertext, :text
    add_column :individuals, :last_name_bidx, :string
    add_column :individuals, :email_ciphertext, :text
    add_column :individuals, :email_bidx, :string
    add_column :individuals, :phone_ciphertext, :text
    add_column :individuals, :phone_bidx, :string
    add_column :individuals, :date_of_birth_ciphertext, :text
    add_column :individuals, :date_of_birth_bidx, :string

    add_column :individuals, :address_ciphertext, :text
    add_column :individuals, :latitude_ciphertext, :text
    add_column :individuals, :longitude_ciphertext, :text
    add_column :individuals, :linkedin_ciphertext, :text
    add_column :individuals, :description_ciphertext, :text

    add_column :individuals, :public_search_text, :string

    add_index :individuals, :email_bidx, unique: true, where: "(email_bidx IS NOT NULL)"
  end
end
