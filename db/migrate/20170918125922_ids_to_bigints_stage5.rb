require_relative './20170918125921_ids_to_bigints_stage4'

class IdsToBigintsStage5 < IdsToBigintsStage4
  disable_ddl_transaction!

  def up
    migrate_column_stage2(:bigint)
  end

  def down
    migrate_column_stage2(:integer)
  end
end
