class PawooRemoveIndexOfExpoPushTokensUserId < ActiveRecord::Migration[5.1]
  def change
    remove_index :pawoo_expo_push_tokens, :user_id
  end
end
