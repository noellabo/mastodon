# frozen_string_literal: true

class Pawoo::LoadAccountMediaAttachmentsService < BaseService
  def call(accounts, limit = 3)
    cache_keys = accounts.map { |account| calc_cache_key(account) }
    cached_keys_with_value = Rails.cache.read_multi(*cache_keys)
    media_attachments_of = MediaAttachment.where(id: cached_keys_with_value.values.flatten).group_by(&:account_id)

    # キャッシュがない、メディアが消えている場合は取得
    fetching_media_attachment_ids = []
    accounts.each do |account|
      cache_key = calc_cache_key(account)
      cached_ids = cached_keys_with_value[cache_key]
      media_attachments = media_attachments_of[account.id]
      next if cached_ids.present? && media_attachments.present? && media_attachments.size == cached_ids.size

      media_attachment_ids = Pawoo::AccountMediaAttachmentIdsQuery.new(account).limit(limit).call
      Rails.cache.write(cache_key, media_attachment_ids, expires_in: 1.hour)
      fetching_media_attachment_ids += media_attachment_ids
    end

    media_attachments_of.merge(MediaAttachment.where(id: fetching_media_attachment_ids).group_by(&:account_id))
  end

  def calc_cache_key(account)
    "pawoo:account_media_attachments:#{account.id}"
  end
end
