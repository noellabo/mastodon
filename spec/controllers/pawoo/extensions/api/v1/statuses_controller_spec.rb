# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::StatusesController, type: :controller do
  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'write') }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    describe 'POST #create' do
      it 'returns http unprocessable entity when published parameter is invalid' do
        post :create, params: { status: 'Hello world', published: 'invalid' }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
