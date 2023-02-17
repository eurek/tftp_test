class AddAccomplishableToAccomplishments < ActiveRecord::Migration[5.2]
  def change
    add_reference :accomplishments, :shareholder, polymorphic: true, index: true
  end
end
