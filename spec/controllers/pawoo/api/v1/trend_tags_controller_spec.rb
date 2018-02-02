require 'rails_helper'

RSpec.describe Pawoo::Api::V1::TrendTagsController, type: :controller do
  render_views

  let!(:suggestion_tag)  { Fabricate(:suggestion_tag, tag: Fabricate(:tag, name: 'suggestion')) }
  let!(:comiket_tag)  { Fabricate(:suggestion_tag, suggestion_type: :comiket, tag: Fabricate(:tag, name: 'comiket')) }

  describe 'GET #index' do
    it 'returns http success' do
      get :index, params: { limit: 1 }

      expect(response).to have_http_status(:success)
    end

    context 'from iOS app' do
      before do
        request.env['HTTP_USER_AGENT'] = 'PawooiOSApp/#1.2.3'
      end

      it 'returns http success' do
        get :index, params: { limit: 1 }

        expect(response).to have_http_status(:success)
      end
    end
  end
end
