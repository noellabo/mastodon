# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Statuses::ReblogsController, type: :controller do
  let(:user)  { Fabricate(:user) }
  let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'write') }

  context 'with an oauth token' do
    before do
      allow(controller).to receive(:doorkeeper_token) { token }
    end

    describe 'POST #create' do
      context 'scheduled' do
        let(:status) { Fabricate(:status, account: user.account, created_at: 1.day.since) }

        it 'returns http not_found' do
          post :create, params: { status_id: status }
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
