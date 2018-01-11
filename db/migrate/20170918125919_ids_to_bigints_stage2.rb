require_relative './20170918125918_ids_to_bigints'

class IdsToBigintsStage2 < IdsToBigints
  disable_ddl_transaction!

  def up
    migrate_column_stage2(:bigint)
  end

  def down
    migrate_column_stage2(:integer)
  end
end
