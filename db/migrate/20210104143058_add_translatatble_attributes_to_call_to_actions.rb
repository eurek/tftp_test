class AddTranslatatbleAttributesToCallToActions < ActiveRecord::Migration[5.2]
  def change
    add_column :call_to_actions, :text_i18n, :jsonb, default: {}
    add_column :call_to_actions, :button_text_i18n, :jsonb, default: {}
    add_column :call_to_actions, :href_i18n, :jsonb, default: {}
  end
end
