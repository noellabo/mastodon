# == Schema Information
#
# Table name: pixiv_follows
#
#  id                      :bigint(8)        not null, primary key
#  target_pixiv_uid        :integer          not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  oauth_authentication_id :bigint(8)        not null
#

class PixivFollow < ApplicationRecord
  belongs_to :oauth_authentication, required: true

  validates :target_pixiv_uid, presence: true
  validates :oauth_authentication_id, uniqueness: { scope: :target_pixiv_uid }

  def self.synchronize!(uids)
    raise 'without scope' unless scope_attributes.present?

    exists = pluck(:target_pixiv_uid)

    deleted_uids = exists - uids
    new_records = (uids - exists).map { |uid| new(target_pixiv_uid: uid) }

    transaction do
      where(target_pixiv_uid: deleted_uids).delete_all
      import!(new_records)
    end
  end
end
