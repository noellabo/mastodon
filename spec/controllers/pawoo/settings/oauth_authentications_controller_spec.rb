require 'rails_helper'

RSpec.describe Pawoo::Settings::OauthAuthenticationsController, type: :controller do
  before do
    sign_in(user, scope: :user)
  end

  let(:user) { Fabricate(:user) }

  describe 'GET #index' do
    before do
      get :index
    end

    it { expect(response).to have_http_status(:success) }

    context 'signed in via pixiv' do
      prepend_before do
        Fabricate(:oauth_authentication, user: user, provider: 'pixiv')
      end

      it { expect(response).to have_http_status(:success) }
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: oauth_authentication.id } }

    let(:oauth_authentication) do
      Fabricate(:oauth_authentication, user: user, provider: 'pixiv')
    end

    context 'if it was the initial password usage' do
      let(:user) { Fabricate(:user, initial_password_usage: Fabricate(:initial_password_usage)) }
      it { is_expected.to redirect_to action: :index }
    end

    context 'if failed' do
      before { allow_any_instance_of(OauthAuthentication).to receive(:destroy).and_return(false) }

      it { is_expected.to redirect_to action: :index }

      it 'flashes an alert' do
        subject
        expect(flash[:alert]).to eq I18n.t('oauth_authentications.failed_linking')
      end
    end

    it 'deletes oauth_authentication' do
      expect{ subject }.to change {
        OauthAuthentication.where(id: oauth_authentication.id).exists?
      }.from(true).to(false)
    end

    it 'redirects to pixiv page' do
      subject
      code = Rails.application.secrets.oauth[:pixiv][:key]
      uid = oauth_authentication.uid
      expect(response).to redirect_to("https://www.pixiv.net/oauth/revoke/?code=#{code}&pixiv_user_id=#{uid}")
    end
  end
end
