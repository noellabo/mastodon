# frozen_string_literal: true

class AddImprovedIndexOnStatusesForApiV1AccountsAccountIdStatuses < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :statuses, [:account_id, :id, :visibility], where: 'visibility IN (0, 1, 2)', algorithm: :concurrently
  end
end
