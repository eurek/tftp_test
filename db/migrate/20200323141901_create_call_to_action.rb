class CreateCallToAction < ActiveRecord::Migration[5.2]
  def change
    create_table :call_to_actions do |t|
      t.string :prismic_id
      t.string :text
      t.string :button_text
      t.string :href
      t.boolean :published, default: false

      t.timestamps
    end

    add_reference :contents, :call_to_action
  end
end
