# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Admin::OauthAuthenticationsController, type: :controller do
  describe 'DELETE #destroy' do
    let (:user) { Fabricate(:user, admin: true) }

    before { sign_in user }

    context 'with destroyable oauth authentication' do
      let (:oauth) { Fabricate(:oauth_authentication) }
      before { delete :destroy, params: { id: oauth } }

      it 'destroys' do
        expect{ oauth.reload }.to raise_error ActiveRecord::RecordNotFound
      end

      it 'flashes success message' do
        expect(flash[:notice]).to eq I18n.t('oauth_authentications.successfully_unlinked')
      end
    end

    context 'with undestroyable oauth authentication' do
      let (:oauth) { Fabricate(:oauth_authentication) }

      before do
        allow_any_instance_of(OauthAuthentication).to receive(:force_destroy).and_return(false)
        delete :destroy, params: { id: oauth }
      end

      it 'flashes failure message' do
        expect(flash[:alert]).to eq I18n.t('oauth_authentications.failed_linking')
      end
    end

    it 'redirects to account path' do
      oauth_account = Fabricate(:account, id: 0)
      oauth_user = Fabricate(:user, account: oauth_account)
      oauth = Fabricate(:oauth_authentication, user: oauth_user)

      delete :destroy, params: { id: oauth }

      expect(response).to redirect_to '/admin/accounts/0'
    end
  end
end
