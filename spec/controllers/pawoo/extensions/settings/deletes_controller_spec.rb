# frozen_string_literal: true

require 'rails_helper'

describe Settings::DeletesController, type: :controller do
  describe 'DELETE #destroy' do
    context 'OAtuh authentication is present' do
      let(:user) { Fabricate(:user, password: 'password') }

      before do
        Fabricate(:oauth_authentication, user: user)
        sign_in user
      end

      subject { delete :destroy, params: { form_delete_confirmation: { password: 'password' } } }

      it { is_expected.to redirect_to settings_delete_path }
    end
  end
end
