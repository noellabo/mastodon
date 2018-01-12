class AddIndexMediaAttachmentAccountIdStatusId < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :media_attachments, [:account_id, :status_id], algorithm: :concurrently
    remove_index :media_attachments, :account_id
  end
end
