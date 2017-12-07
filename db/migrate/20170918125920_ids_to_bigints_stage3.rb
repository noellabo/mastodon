require_relative './20170918125918_ids_to_bigints'

class IdsToBigintsStage3 < IdsToBigints
  disable_ddl_transaction!

  def up
    migrate_column_stage3(:bigint)
  end

  def down
    migrate_column_stage1(:integer)
  end
end
