class AddMultipleIndexesToImprovePerformances < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index :active_storage_blobs, :checksum, algorithm: :concurrently
    add_index :individuals, :external_uid, algorithm: :concurrently
    add_index :individuals, :public_slug, algorithm: :concurrently
    add_index :notifications, :created_at, algorithm: :concurrently
    add_index :shares_purchases, :transfer_reference, algorithm: :concurrently
    add_index :shares_purchases, :typeform_answer_uid, algorithm: :concurrently
  end
end
