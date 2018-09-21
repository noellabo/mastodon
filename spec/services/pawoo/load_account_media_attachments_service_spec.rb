require 'rails_helper'

describe Pawoo::LoadAccountMediaAttachmentsService do
  describe '.call' do
    subject { Pawoo::LoadAccountMediaAttachmentsService.new.call(accounts, limit) }
    let(:accounts) { Fabricate.times(3, :account) }
    let!(:media_attachments) do
      accounts.map do |account|
        status = Fabricate(:status, account: account)
        Fabricate(:media_attachment, account: account, status: status, created_at: status.created_at, file: nil)
      end
    end
    let(:limit) { 3 }

    context 'when cache does not exist' do
      it 'returns hash of media attachments' do
        expect(subject.keys).to match_array accounts.map(&:id)
        expect(subject[media_attachments[0].account.id].first).to eq media_attachments[0]
        expect(subject[media_attachments[1].account.id].first).to eq media_attachments[1]
        expect(subject[media_attachments[2].account.id].first).to eq media_attachments[2]
      end
    end

    context 'when cached media is deleted' do
      before do
        Rails.cache.write("pawoo:account_media_attachments:#{accounts[0].id}", [0])
        allow(Pawoo::AccountMediaAttachmentIdsQuery).to receive(:new).and_call_original
      end

      it 'call Pawoo::AccountMediaAttachmentIdsQuery' do
        subject
        expect(Pawoo::AccountMediaAttachmentIdsQuery).to have_received(:new).with(accounts[0])
      end
    end

    context 'when cache exists' do
      before do
        media_attachments.each do |media_attachment|
          Rails.cache.write("pawoo:account_media_attachments:#{media_attachment.account.id}", [media_attachment.id])
        end
        allow(Pawoo::AccountMediaAttachmentIdsQuery).to receive(:new).and_call_original
      end

      it 'does not call Pawoo::AccountMediaAttachmentIdsQuery' do
        subject
        expect(Pawoo::AccountMediaAttachmentIdsQuery).not_to have_received(:new)
      end
    end

    context 'when having multiple media' do
      let(:accounts) { [account] }
      let(:account) { Fabricate(:account) }
      let(:media_attachment_ids) { Fabricate.times(3, :media_attachment, account: account, file: nil).map(&:id).shuffle }

      before do
        query = Pawoo::AccountMediaAttachmentIdsQuery.new(account)
        allow(Pawoo::AccountMediaAttachmentIdsQuery).to receive(:new).and_return(query)
        allow(query).to receive(:call).and_return(media_attachment_ids)
      end

      it 'returns media attachments in the same order' do
        expect(subject[account.id].map(&:id)).to match media_attachment_ids
      end
    end
  end
end
