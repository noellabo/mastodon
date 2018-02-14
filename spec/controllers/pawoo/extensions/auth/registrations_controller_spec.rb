# frozen_string_literal: true

require 'rails_helper'

describe Auth::RegistrationsController, type: :controller do
  let(:user) { Fabricate(:user) }

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    sign_in user
  end

  describe 'GET #edit' do
    it 'stores current location' do
      get :edit
      expect(controller.stored_location_for(:user)).to eq '/auth/edit'
    end
  end

  describe 'GET #update' do
    context 'if it is the initial password usage' do
      before { Fabricate(:initial_password_usage, user: user) }
      subject { get :update }

      context 'when it fails to send reset password instructions' do
        before { allow(controller).to receive(:successfully_sent?).and_return(false) }

        it { is_expected.to render_template :edit }
        it { is_expected.to have_http_status :unprocessable_entity }
      end

      it 'sends reset password instructions' do
        ActionMailer::Base.deliveries.clear
        subject
        expect(ActionMailer::Base.deliveries.first.to).to eq [user.email]
      end

      it { is_expected.to redirect_to edit_user_registration_path }
    end
  end
end
