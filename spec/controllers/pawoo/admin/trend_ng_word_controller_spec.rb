require 'rails_helper'

describe Pawoo::Admin::TrendNgWordsController, type: :controller do
  render_views

  let(:trend_ng_word) { Fabricate(:trend_ng_word) }
  before do
    sign_in Fabricate(:user, admin: true), scope: :user
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    it 'redirects to admin trend ng word page' do
      post :create, params: { trend_ng_word: { word: Fabricate.sequence(:word), memo: Faker::Lorem.sentence } }

      expect(response).to redirect_to(admin_trend_ng_words_path)
    end

    it 'same word is not permitted' do
      post :create, params: { trend_ng_word: { word: trend_ng_word.word, memo: Faker::Lorem.sentence } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH #update' do
    it 'redirects to admin trend ng word page' do
      patch :update, params: { id: trend_ng_word.id, trend_ng_word:{ word: Fabricate.sequence(:word), memo: Faker::Lorem.sentence } }

      expect(response).to redirect_to(admin_trend_ng_words_path)
    end

    it 'same word is not permitted' do
      patch :update, params: { id: Fabricate(:trend_ng_word).id, trend_ng_word:{ word: trend_ng_word.word, memo: Faker::Lorem.sentence } }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE #destroy' do
    it 'redirects to admin trend ng word page' do
      delete :destroy, params: { id: trend_ng_word.id }

      expect(response).to redirect_to(admin_trend_ng_words_path)
    end
  end
end
