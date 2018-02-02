# frozen_string_literal: true

require 'rails_helper'

describe AboutController, type: :controller do
  describe 'GET #app_eula' do
    it 'returns http success' do
      get :app_eula
      expect(response).to have_http_status(:success)
    end
  end
end
