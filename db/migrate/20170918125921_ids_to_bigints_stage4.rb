require_relative './20170918125918_ids_to_bigints'

class IdsToBigintsStage4 < IdsToBigints
  disable_ddl_transaction!

  INCLUDED_COLUMNS = [
    [:blocks, :target_account_id],
    [:favourites, :id],
    [:favourites, :status_id],
    [:follows, :id],
    [:follows, :target_account_id],
    [:follow_requests, :id],
    [:follow_requests, :target_account_id],
    [:mutes, :id],
    [:mutes, :target_account_id],
    [:notifications, :id],
    [:notifications, :from_account_id],
    [:stream_entries, :account_id]
  ]

  def ordered_columns
    tables = INCLUDED_COLUMNS.map(&:first).uniq
    table_sizes = {}

    # Sort tables by their size
    tables.each do |table|
      table_sizes[table] = estimate_rows_in_table(table)
    end

    INCLUDED_COLUMNS.sort_by do |col_parts|
      [-table_sizes[col_parts.first], col_parts.last]
    end
  end

  def up
    # 20180109204141_add_index_on_follow_account_id_idを先に入れてた場合用の対策
    # 一時的なコピー用のindexの名前が重複するため、影響の少ない[:target_account_id, :id]のindexを一旦削除(レコード数はそこまで大きくないため、時間は1分もかからない)
    # 一旦削除しない場合は2回に分けて行う作業が3回になってしまうので…
    if indexes(:follows).map(&:name).include?('index_follows_on_target_account_id_and_id')
      add_index :follows, :target_account_id, algorithm: :concurrently, name: :index_follows_for_migratiton_20170918125921
      remove_index :follows, name: :index_follows_on_target_account_id_and_id
    end

    migrate_column_stage1(:bigint)
  end

  def down
    migrate_column_stage3(:integer)
  end
end
