class CreateIndividuals < ActiveRecord::Migration[6.1]
  def change
    create_table :individuals do |t|
      t.string :first_name
      t.string :last_name
      t.string :email, null: false, default: ""
      t.string :phone
      t.date :date_of_birth
      t.text :address
      t.string :city
      t.string :zip_code
      t.string :country
      t.references :employer, foreign_key: {to_table: :companies}
      t.text :origin
      t.string :typeform_language
      t.string :communication_language
      t.string :nationality
      t.string :department_number
      t.string :linkedin_url
      t.float :latitude
      t.float :longitude
      t.boolean :is_100_club
      t.string :stacker_role
    end

    add_reference :users, :individual
  end
end
