class PawooAddIndexOnReportTarget < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :pawoo_report_targets, [:state, :target_type, :target_id], algorithm: :concurrently, name: :pawoo_report_target_index_state_and_target
  end
end
