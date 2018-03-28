class PawooCreateReportSummations < ActiveRecord::Migration[5.1]
  def change
    create_table :pawoo_report_summations do |t|
      t.date :date, null: false
      t.integer :total_count, null: false, default: 0
      t.integer :other_count, null: false, default: 0
      t.integer :prohibited_count, null: false, default: 0
      t.integer :reproduction_count, null: false, default: 0
      t.integer :spam_count, null: false, default: 0
      t.integer :nsfw_count, null: false, default: 0
      t.integer :donotlike_count, null: false, default: 0
      t.integer :other_count, null: false, default: 0

      t.index :date, unique: true
    end
  end
end
