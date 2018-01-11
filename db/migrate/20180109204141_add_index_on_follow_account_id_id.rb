class AddIndexOnFollowAccountIdId < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :follows, [:account_id, :id], algorithm: :concurrently
    add_index :follows, [:target_account_id, :id], algorithm: :concurrently
    remove_index :follows, name: :index_follows_on_target_account_id
  end
end
