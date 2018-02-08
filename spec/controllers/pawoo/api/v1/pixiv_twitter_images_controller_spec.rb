require 'rails_helper'

RSpec.describe Pawoo::Api::V1::PixivTwitterImagesController, type: :controller do
  describe 'GET #create' do
    subject do
      post :create
    end

    context 'with valid pixiv URL' do
      before do
        stub_request(:get, 'https://www.pixiv.net/member.php?id=1')
          .to_return(status: 200, body: File.read('spec/fixtures/pixiv/user_page.html'))
      end

      subject do
        post :create, params: { url: 'https://www.pixiv.net/member.php?id=1' }
      end

      it 'does not enqueue FetchPixivTwitterImageWorker if it is already cached' do
        PixivUrl::PixivTwitterImage.cache_or_fetch 'https://www.pixiv.net/member.php?id=1'

        Sidekiq::Testing.fake! do
          subject
          expect(FetchPixivTwitterImageWorker).not_to have_enqueued_sidekiq_job 'https://www.pixiv.net/member.php?id=1'
        end
      end

      it 'enqueues FetchPixivTwitterImageWorker' do
        Sidekiq::Testing.fake! do
          subject
          expect(FetchPixivTwitterImageWorker).to have_enqueued_sidekiq_job 'https://www.pixiv.net/member.php?id=1'
        end
      end
    end

    it { is_expected.to have_http_status(:no_content) }
  end
end
