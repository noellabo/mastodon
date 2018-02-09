require 'rails_helper'

RSpec.describe Pawoo::Api::V1::TrendTagsController, type: :controller do
  render_views

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end

    it 'limits the number' do
      2.times.each { Fabricate(:suggestion_tag, suggestion_type: 'normal') }
      get :index, params: { limit: 1 }
      expect(body_as_json.size).to eq 1
    end
  end
end
