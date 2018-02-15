# frozen_string_literal: true

require 'rails_helper'

describe Auth::SessionsController, type: :controller do
  describe 'DELETE #destroy' do
    context 'with OAuth authentication' do
      let(:authentication) { Fabricate(:oauth_authentication) }

      before do
        request.env['devise.mapping'] = Devise.mappings[:user]
        sign_in authentication.user
      end

      subject { delete :destroy }
      it { is_expected.to redirect_to 'https://www.pixiv.net/logout.php?return_to=http%3A%2F%2Ftest.host%2F' }
    end
  end
end
