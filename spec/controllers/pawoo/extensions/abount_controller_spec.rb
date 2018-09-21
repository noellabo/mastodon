# frozen_string_literal: true

require 'rails_helper'

describe AboutController, type: :controller do
  describe 'GET #app_eula' do
    it 'returns http success' do
      get :app_eula
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #app_terms' do
    it 'returns http success' do
      get :app_terms
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    context 'if user has signed in' do
      let(:user) { Fabricate(:user) }

      subject do
        sign_in user
        get :show
      end

      it { is_expected.to redirect_to root_url }
    end
  end
end
