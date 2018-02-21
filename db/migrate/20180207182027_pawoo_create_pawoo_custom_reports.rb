require Rails.root.join('lib', 'mastodon', 'migration_helpers')

class PawooCreatePawooCustomReports < ActiveRecord::Migration[5.1]
  include Mastodon::MigrationHelpers

  disable_ddl_transaction!

  def up
    create_table :pawoo_report_targets do |t|
      t.bigint :report_id, null: false
      t.string :target_type, null: false
      t.bigint :target_id, null: false
      t.integer :state, default: 0, null: false
    end

    safety_assured { add_column_with_default :reports, :pawoo_report_type, :integer, default: 0, allow_null: false }
  end

  def down
    drop_table :pawoo_report_targets
    remove_column :reports, :pawoo_report_type
  end
end
