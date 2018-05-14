class AddIndexAccountIdAndVisibilityAndIdOnStatuses < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def up
    safety_assured do
      add_index :statuses, [:account_id, :visibility, :id], order: { id: :desc }, algorithm: :concurrently
    end
  end

  def down
    remove_index :statuses, [:account_id, :visibility, :id]
  end
end
