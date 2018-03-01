# frozen_string_literal: true

class Pawoo::LoadAccountMediaAttachmentsService < BaseService
  def call(accounts, limit = 3)
    cache_keys = accounts.map { |account| calc_cache_key(account.id) }
    cached_keys_with_value = Rails.cache.read_multi(*cache_keys)
    tmp_media_attachments_of = MediaAttachment.where(id: cached_keys_with_value.values.flatten).group_by(&:account_id)

    # キャッシュがない、メディアが消えている場合は取得
    fetching_media_attachment_ids = []
    accounts.each do |account|
      cache_key = calc_cache_key(account.id)
      cached_ids = cached_keys_with_value[cache_key]
      media_attachments = tmp_media_attachments_of[account.id]
      next if cached_ids.present? && media_attachments.present? && media_attachments.size == cached_ids.size

      media_attachment_ids = Pawoo::AccountMediaAttachmentIdsQuery.new(account).limit(limit).call
      Rails.cache.write(cache_key, media_attachment_ids, expires_in: 1.hour)
      cached_keys_with_value[cache_key] = media_attachment_ids
      fetching_media_attachment_ids += media_attachment_ids
    end

    tmp_media_attachments_of.merge!(MediaAttachment.where(id: fetching_media_attachment_ids).group_by(&:account_id))

    media_attachments_of = {}
    tmp_media_attachments_of.each do |account_id, media_attachments|
      cache_key = calc_cache_key(account_id)
      media_attachment_ids = cached_keys_with_value[cache_key].map(&:to_i)
      media_attachments_of[account_id] = media_attachments.sort_by { |media_attachment| media_attachment_ids.index(media_attachment.id) }
    end
    media_attachments_of
  end

  def calc_cache_key(account_id)
    "pawoo:account_media_attachments:#{account_id}"
  end
end
