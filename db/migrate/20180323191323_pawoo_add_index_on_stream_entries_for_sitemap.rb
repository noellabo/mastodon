class PawooAddIndexOnStreamEntriesForSitemap < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :stream_entries, [:activity_type, :hidden, :id], algorithm: :concurrently
  end
end
