class RemoveIndexStatuses20180106OnStatuses < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    remove_index :statuses, name: :index_statuses_20180106
  end

  def down
    safety_assured do
      add_index :statuses, [:account_id, :id, :visibility, :updated_at], order: { id: :desc }, algorithm: :concurrently, name: :index_statuses_20180106
    end
  end
end
