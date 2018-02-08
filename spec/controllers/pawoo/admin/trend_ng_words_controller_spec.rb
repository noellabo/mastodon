# frozen_string_literal: true

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

  describe 'GET #new' do
    it 'returns http success' do
      get :new

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      before do
        post :create, params: { trend_ng_word: { word: 'AUniqueWord', memo: 'A memo.' } }
      end

      it 'saves word' do
        expect(TrendNgWord.where(word: 'AUniqueWord', memo: 'A memo.')).to exist
      end

      it 'flashes a success message' do
        expect(flash[:notice]).to eq 'NGワードを追加しました'
      end

      it 'redirects to admin trend ng word page' do
        expect(response).to redirect_to(admin_trend_ng_words_path)
      end
    end

    context 'with invalid parameters' do
      subject do
        post :create, params: { trend_ng_word: { word: trend_ng_word.word, memo: Faker::Lorem.sentence } }
      end

      it { is_expected.to have_http_status :unprocessable_entity }
      it { is_expected.to render_template :new }
    end
  end

  describe 'GET #edit' do
    it 'returns http success' do
      get :edit, params: { id: trend_ng_word }

      expect(response).to have_http_status :success
    end
  end

  describe 'PATCH #update' do
    context 'with valid parameters' do
      before do
        patch :update, params: { id: trend_ng_word.id, trend_ng_word: { word: 'AUniqueWord', memo: 'A memo.' } }
      end

      it 'updates word' do
        trend_ng_word.reload
        expect(trend_ng_word.word).to eq 'AUniqueWord'
        expect(trend_ng_word.memo).to eq 'A memo.'
      end

      it 'flashes a success message' do
        expect(flash[:notice]).to eq 'NGワードを更新しました'
      end

      it 'redirects to admin trend ng word page' do
        expect(response).to redirect_to(admin_trend_ng_words_path)
      end
    end

    context 'with invalid parameters' do
      subject do
        patch :update, params: { id: Fabricate(:trend_ng_word).id, trend_ng_word: { word: trend_ng_word.word, memo: Faker::Lorem.sentence } }
      end

      it { is_expected.to have_http_status :unprocessable_entity }
      it { is_expected.to render_template :edit }
    end
  end

  describe 'DELETE #destroy' do
    before do
      delete :destroy, params: { id: trend_ng_word.id }
    end

    it 'destroys a word' do
      expect{ trend_ng_word.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'flashes a success message' do
      expect(flash[:notice]).to eq 'NGワードを削除しました'
    end

    it 'redirects to admin trend ng word page' do
      expect(response).to redirect_to(admin_trend_ng_words_path)
    end
  end
end
