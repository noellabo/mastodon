class CreatePawooGalleries < ActiveRecord::Migration[5.2]
  def change
    create_table :pawoo_galleries do |t|
      t.references :tag, null: false
      t.text :description, null: false, default: ''
      t.boolean :published, null: false, default: false
      t.attachment :image
      t.bigint :max_id
      t.bigint :min_id

      t.timestamps
    end

    remove_index :pawoo_galleries, :tag_id
    add_index :pawoo_galleries, :tag_id, unique: true


    create_table :pawoo_gallery_blacklisted_statuses do |t|
      t.references :status, foreign_key: { on_delete: :cascade }, null: false
      t.references :pawoo_gallery, foreign_key: { on_delete: :cascade }, null: false
    end

    remove_index :pawoo_gallery_blacklisted_statuses, :pawoo_gallery_id
    add_index :pawoo_gallery_blacklisted_statuses, [:pawoo_gallery_id, :status_id], unique: true, name: :index_pawoo_gallery_id_and_status_id
  end
end
