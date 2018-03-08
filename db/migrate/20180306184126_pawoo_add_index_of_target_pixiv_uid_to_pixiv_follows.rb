class PawooAddIndexOfTargetPixivUidToPixivFollows < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :pixiv_follows, :target_pixiv_uid, algorithm: :concurrently
  end
end
