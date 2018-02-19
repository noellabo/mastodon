require 'rails_helper'

describe Pawoo::LoadAccountMediaAttachmentsService do
  describe '.call' do
    subject { Pawoo::LoadAccountMediaAttachmentsService.new.call(accounts, limit) }
    let(:accounts) { Fabricate.times(3, :account) }
    let!(:media_attachments) do
      accounts.map do |account|
        status = Fabricate(:status, account: account)
        Fabricate(:media_attachment, account: account, status: status, created_at: status.created_at)
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
  end
end
