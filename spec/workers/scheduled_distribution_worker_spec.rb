# frozen_string_literal: true

require 'rails_helper'

describe ScheduledDistributionWorker do
  describe 'perform' do
    TEXT = 'the text of a status made by ScheduledDistributionWorker'
    MENTIONING_TEXT = 'the text of a status made by ScheduledDistributionWorker, mentioning @alice'

    it 'updates id' do
      old_status = Fabricate(:status, text: TEXT)
      old_id = old_status.id

      ScheduledDistributionWorker.new.perform(old_status.id)

      new_statuses = Status.where(text: TEXT)

      expect(new_statuses.size).to eq 1
      expect(new_statuses[0].id).not_to eq old_id
    end

    it 'updates stream entry' do
      old_status = Fabricate(:status, text: TEXT)
      old_stream_entry = old_status.stream_entry

      ScheduledDistributionWorker.new.perform(old_status.id)

      new_status = Status.find_by!(text: TEXT)
      new_stream_entry = new_status.stream_entry

      expect(new_stream_entry).not_to eq old_stream_entry
    end

    it 'updates media attachments' do
      old_status = Fabricate(:status, text: TEXT)
      old_media_attachments = [Fabricate(:media_attachment, status: old_status)]

      ScheduledDistributionWorker.new.perform(old_status.id)

      new_status = Status.find_by!(text: TEXT)
      new_media_attachments = new_status.media_attachments

      expect(new_media_attachments).to match_array old_media_attachments
    end

    it 'updates preview card' do
      old_preview_cards = [Fabricate(:preview_card)]
      old_status = Fabricate(:status, text: TEXT, preview_cards: old_preview_cards)

      ScheduledDistributionWorker.new.perform(old_status.id)

      new_status = Status.find_by!(text: TEXT)
      new_preview_cards = new_status.preview_cards

      expect(new_preview_cards).to eq old_preview_cards
    end

    it 'updates pixiv cards' do
      old_status = Fabricate(:status, text: TEXT)
      old_pixiv_cards = [Fabricate(:pixiv_card, status: old_status)]

      ScheduledDistributionWorker.new.perform(old_status.id)

      new_status = Status.find_by!(text: TEXT)
      new_pixiv_cards = new_status.pixiv_cards

      expect(new_pixiv_cards).to match_array old_pixiv_cards
    end

    it 'updates tags' do
      old_tags = [Fabricate(:tag)]
      old_status = Fabricate(:status, text: TEXT, tags: old_tags)

      ScheduledDistributionWorker.new.perform(old_status.id)

      new_status = Status.find_by!(text: TEXT)
      new_tags = new_status.tags

      expect(new_tags).to match_array old_tags
    end

    it 'processes mentions' do
      old_status = Fabricate(:status, text: MENTIONING_TEXT)
      alice = Fabricate(:account, domain: nil, username: 'alice')
      Fabricate(:user, account: alice)

      ScheduledDistributionWorker.new.perform(old_status.id)

      new_status = Status.find_by!(text: MENTIONING_TEXT)
      new_mentions = new_status.mentions

      Notification.find_by!(account: alice, activity: new_mentions.find_by!(account: alice))
    end

    it 'distributes status' do
      old_status = Fabricate(:status, text: TEXT)

      Sidekiq::Testing.fake! do
        ScheduledDistributionWorker.new.perform(old_status.id)

        new_status = Status.find_by!(text: TEXT)

        expect(DistributionWorker).to have_enqueued_sidekiq_job new_status.id
      end
    end

    it 'distributes statuses via Pubsubhubbub' do
      old_status = Fabricate(:status, text: TEXT)

      Sidekiq::Testing.fake! do
        ScheduledDistributionWorker.new.perform(old_status.id)

        new_status = Status.find_by!(text: TEXT)
        new_stream_entry = new_status.stream_entry

        expect(Pubsubhubbub::DistributionWorker).to have_enqueued_sidekiq_job new_stream_entry.id
      end
    end

    it 'distributes statuses via ActivityPub' do
      old_status = Fabricate(:status, text: TEXT)

      Sidekiq::Testing.fake! do
        ScheduledDistributionWorker.new.perform(old_status.id)

        new_status = Status.find_by!(text: TEXT)

        expect(ActivityPub::DistributionWorker).to have_enqueued_sidekiq_job new_status.id
      end
    end
  end
end
