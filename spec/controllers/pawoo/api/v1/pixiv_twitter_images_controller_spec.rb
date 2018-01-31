require 'rails_helper'

RSpec.describe Pawoo::Api::V1::PixivTwitterImagesController, type: :controller do
  describe 'GET #create' do
    before do
      stub_request(:get, "https://www.pixiv.net/member.php?id=1")
        .to_return(status: 200, body: File.read('spec/fixtures/pixiv/user_page.html'))
    end

    it 'returns http no_content' do
      post :create, params: { url: 'https://www.pixiv.net/member.php?id=1' }
      expect(response).to have_http_status(:no_content)
    end
  end
end
