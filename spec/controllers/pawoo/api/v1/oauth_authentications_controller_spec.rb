require 'rails_helper'

RSpec.describe Pawoo::Api::V1::OauthAuthenticationsController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:token) { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'GET #show' do
    before do
      get :show, params: { uid: uid }
    end

    context 'given valid uid' do
      let(:oauth_authentication) { Fabricate(:oauth_authentication) }
      let(:uid) { oauth_authentication.uid }
      it { expect(response).to have_http_status(:success) }
    end

    context 'given invalid uid' do
      let(:uid) { 1 }
      it { expect(response).to have_http_status(:not_found) }
    end
  end
end
