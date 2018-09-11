require 'rails_helper'

RSpec.describe Pawoo::Gallery, type: :model do
  describe '#filtered_statuses' do
    subject { gallery.filtered_statuses(limit, paginate_max_id, paginate_since_id) }

    let(:gallery) { Fabricate('Pawoo::Gallery', tag: tag, max_id: max_id, min_id: min_id) }
    let(:tag) { Fabricate(:tag) }
    let(:limit) { 30 }
    let(:paginate_max_id) { nil }
    let(:paginate_since_id) { nil }
    let(:max_id) { nil }
    let(:min_id) { nil }

    it 'includes statuses with a tag and media' do
      status = Fabricate(:status, tags: [tag])
      Fabricate(:media_attachment, status: status, file: nil)

      no_media_status = Fabricate(:status, tags: [tag])

      no_tag_status = Fabricate(:status)
      Fabricate(:media_attachment, status: no_tag_status, file: nil)

      results = subject
      expect(results).to include(status)
      expect(results).not_to include(no_media_status)
      expect(results).not_to include(no_tag_status)
    end

    it 'allows replies to be included' do
      original = Fabricate(:status)
      status = Fabricate(:status, tags: [tag], in_reply_to_id: original.id)
      Fabricate(:media_attachment, status: status, file: nil)

      expect(subject).to include(status)
    end

    it 'allows public and unlisted status to be included' do
      public_status = Fabricate(:status, tags: [tag], visibility: :public)
      Fabricate(:media_attachment, status: public_status, file: nil)

      unlisted_status = Fabricate(:status, tags: [tag], visibility: :unlisted)
      Fabricate(:media_attachment, status: unlisted_status, file: nil)

      private_status = Fabricate(:status, tags: [tag], visibility: :private)
      Fabricate(:media_attachment, status: private_status, file: nil)

      direct_status = Fabricate(:status, tags: [tag], visibility: :direct)
      Fabricate(:media_attachment, status: direct_status, file: nil)

      results = subject
      expect(results).to include(public_status)
      expect(results).to include(unlisted_status)
      expect(results).not_to include(private_status)
      expect(results).not_to include(direct_status)
    end

    it 'does not include boosts' do
      status = Fabricate(:status, tags: [tag])
      Fabricate(:media_attachment, status: status, file: nil)
      boost = Fabricate(:status, reblog_of_id: status.id)

      results = subject
      expect(results).to include(status)
      expect(results).not_to include(boost)
    end

    it 'filters out silenced accounts' do
      account = Fabricate(:account)
      silenced_account = Fabricate(:account, silenced: true)
      status = Fabricate(:status, tags: [tag], account: account)
      Fabricate(:media_attachment, status: status, file: nil)
      silenced_status = Fabricate(:status, tags: [tag], account: silenced_account)
      Fabricate(:media_attachment, status: silenced_status, file: nil)

      results = subject
      expect(results).to include(status)
      expect(results).not_to include(silenced_status)
    end

    it 'filters out blacklisted status' do

      status = Fabricate(:status, tags: [tag])
      Fabricate(:media_attachment, status: status, file: nil)
      gallery.gallery_blacklisted_statuses.create!(status: status)

      expect(subject).not_to include(status)
    end

    context 'when max_id is set' do
      let(:max_id) { Mastodon::Snowflake.id_at(3.day.ago) }

      context 'whne paginate_max_id is nil' do
        it 'filter by max_id' do
          latest_status = Fabricate(:status, tags: [tag], created_at: 2.day.ago)
          Fabricate(:media_attachment, status: latest_status, file: nil)
          old_status = Fabricate(:status, tags: [tag], created_at: 6.days.ago)
          Fabricate(:media_attachment, status: old_status, file: nil)

          results = subject
          expect(results).not_to include(latest_status)
          expect(results).to include(old_status)
        end
      end

      context 'when paginate_max_id is not nil' do
        context 'when paginate_max_id > max_id' do
          let(:paginate_max_id) { Mastodon::Snowflake.id_at(1.day.ago) }

          it 'filter by max_id' do
            latest_status = Fabricate(:status, tags: [tag], created_at: 2.day.ago)
            Fabricate(:media_attachment, status: latest_status, file: nil)
            old_status = Fabricate(:status, tags: [tag], created_at: 6.days.ago)
            Fabricate(:media_attachment, status: old_status, file: nil)

            results = subject
            expect(results).not_to include(latest_status)
            expect(results).to include(old_status)
          end
        end

        context 'when paginate_max_id < max_id' do
          let(:paginate_max_id) { Mastodon::Snowflake.id_at(5.day.ago) }

          it 'filter by paginate_max_id' do
            latest_status = Fabricate(:status, tags: [tag], created_at: 4.day.ago)
            Fabricate(:media_attachment, status: latest_status, file: nil)
            old_status = Fabricate(:status, tags: [tag], created_at: 6.days.ago)
            Fabricate(:media_attachment, status: old_status, file: nil)

            results = subject
            expect(results).not_to include(latest_status)
            expect(results).to include(old_status)
          end
        end
      end
    end

    context 'when min_id is set' do
      let(:min_id) { Mastodon::Snowflake.id_at(3.day.ago) }

      context 'whne paginate_since_id is nil' do
        it 'filter by min_id' do
          latest_status = Fabricate(:status, tags: [tag], created_at: 2.day.ago)
          Fabricate(:media_attachment, status: latest_status, file: nil)
          old_status = Fabricate(:status, tags: [tag], created_at: 4.days.ago)
          Fabricate(:media_attachment, status: old_status, file: nil)

          results = subject
          expect(results).to include(latest_status)
          expect(results).not_to include(old_status)
        end
      end

      context 'when paginate_since_id is not nil' do
        context 'when paginate_since_id > min_id' do
          let(:paginate_since_id) { Mastodon::Snowflake.id_at(1.day.ago) }

          it 'filter by paginate_since_id' do
            latest_status = Fabricate(:status, tags: [tag], created_at: Time.current)
            Fabricate(:media_attachment, status: latest_status, file: nil)
            old_status = Fabricate(:status, tags: [tag], created_at: 2.days.ago)
            Fabricate(:media_attachment, status: old_status, file: nil)

            results = subject
            expect(results).to include(latest_status)
            expect(results).not_to include(old_status)
          end
        end

        context 'when paginate_since_id < min_id' do
          let(:paginate_since_id) { Mastodon::Snowflake.id_at(5.day.ago) }

          it 'filter by min_id' do
            latest_status = Fabricate(:status, tags: [tag], created_at: 2.day.ago)
            Fabricate(:media_attachment, status: latest_status, file: nil)
            old_status = Fabricate(:status, tags: [tag], created_at: 4.days.ago)
            Fabricate(:media_attachment, status: old_status, file: nil)

            results = subject
            expect(results).to include(latest_status)
            expect(results).not_to include(old_status)
          end
        end
      end
    end

    context 'when limit is 1' do
      let(:limit) { 1 }

      it 'return 1 status' do
        Fabricate.times(2, :status, tags: [tag]).each do |status|
          Fabricate(:media_attachment, status: status, file: nil)
        end

        expect(subject.size).to eq 1
      end
    end
  end
end
