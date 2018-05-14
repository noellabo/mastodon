class RemoveIndexStatuses20180106OnStatuses < ActiveRecord::Migration[5.1]
  def change
    remove_index :statuses, name: :index_statuses_20180106
  end
end
