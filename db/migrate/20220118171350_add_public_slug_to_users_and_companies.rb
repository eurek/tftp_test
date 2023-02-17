class AddPublicSlugToUsersAndCompanies < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :public_slug, :string
    add_column :companies, :public_slug, :string
    add_index :users, :public_slug, unique: true
    add_index :companies, :public_slug, unique: true
  end
end
