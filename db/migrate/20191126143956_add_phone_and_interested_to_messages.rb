class AddPhoneAndInterestedToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :sender_phone, :string
    add_column :messages, :interested_to_invest, :boolean, nullable: false, default: false
  end
end
