require_relative './20170918125921_ids_to_bigints_stage4'

class IdsToBigintsStage6 < IdsToBigintsStage4
  disable_ddl_transaction!

  def up
    migrate_column_stage3(:bigint)

    # 一旦削除していた複合indexを戻す
    if indexes(:follows).map(&:name).include?('index_follows_for_migratiton_20170918125921')
      add_index :follows, [:target_account_id, :id], algorithm: :concurrently, name: :index_follows_on_target_account_id_and_id
      remove_index :follows, name: :index_follows_for_migratiton_20170918125921
    end
  end

  def down
    migrate_column_stage1(:integer)
  end
end
