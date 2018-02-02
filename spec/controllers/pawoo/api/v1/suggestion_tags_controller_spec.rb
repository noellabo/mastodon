require 'rails_helper'

RSpec.describe Pawoo::Api::V1::SuggestionTagsController, type: :controller do
  render_views

  let!(:suggestion_tag)  { Fabricate(:suggestion_tag, tag: Fabricate(:tag, name: 'suggestion')) }

  describe 'GET #index' do
    subject do
      -> { get :index, params: { limit: 1, type: type } }
    end

    context 'given valid parameters' do
      let(:type) { 'comiket' }

      it 'returns http success' do
        subject.call
        expect(response).to have_http_status(:success)
      end
    end

    context 'given invalid parameters' do
      let(:type) { 'invalid' }

      it 'returns http unprocessable_entity' do
        subject.call
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
