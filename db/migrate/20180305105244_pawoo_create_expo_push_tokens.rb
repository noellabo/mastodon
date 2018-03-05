class PawooCreateExpoPushTokens < ActiveRecord::Migration[5.1]
  def change
    create_table :pawoo_expo_push_tokens do |t|
      t.belongs_to :user, foreign_key: { on_delete: :cascade }, null: false
      t.string :token, null: false
      t.index [:user_id, :token], unique: true
    end
  end
end
