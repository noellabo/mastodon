require 'rails_helper'

RSpec.describe Pawoo::OauthAuthenticationsController, type: :controller do
  describe 'GET #show' do
    before do
      get :show, params: { uid: uid }
    end

    context 'given valid uid' do
      let(:oauth_authentication) { Fabricate(:oauth_authentication) }
      let(:uid) { oauth_authentication.uid }
      it { is_expected.to redirect_to(short_account_path(oauth_authentication.user.account)) }
    end

    context 'given invalid uid' do
      let(:uid) { 1 }
      it { expect(response).to have_http_status(:not_found) }
    end
  end
end
