class RemoveExternalUidFromEpisodes < ActiveRecord::Migration[6.1]
  def change
    remove_column :episodes, :external_uid, :string
  end
end
