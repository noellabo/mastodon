class AddIndexAccountIdAndVisibilityAndIdOnStatuses < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_index :statuses, [:account_id, :visibility, :id], order: { id: :desc }, algorithm: :concurrently
    end
  end
end
