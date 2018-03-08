require 'rails_helper'

RSpec.describe Pawoo::Api::V1::ExpoPushTokensController, type: :controller do
  let(:user)     { Fabricate(:user, account: Fabricate(:account)) }
  let(:token)    { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'POST #create' do
    subject do
      -> { post :create, params: expo_push_token_params }
    end
    let(:expo_push_token_params) { { token: 'ExponentPushToken[xxx]' } }

    context 'given valid parameters' do
      it 'returns http success' do
        subject.call
        expect(response).to have_http_status(:success)
      end

      it { is_expected.to change(Pawoo::ExpoPushToken, :count).by(1) }
    end

    context 'given invalid parameters' do
      let(:expo_push_token_params) { { token: nil } }

      it 'returns http unprocessable_entity' do
        subject.call
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it { is_expected.to_not change(Pawoo::ExpoPushToken, :count).from(0) }
    end
  end


  describe 'DELETE #destroy' do
    subject do
      -> { delete :destroy, params: expo_push_token_params }
    end

    let!(:pawoo_expo_push_token) { Fabricate('Pawoo::ExpoPushToken', token: 'ExponentPushToken[xxx]', user: user) }

    context 'given valid parameters' do
      let(:expo_push_token_params) { { token: 'ExponentPushToken[xxx]' } }

      it 'returns http success' do
        subject.call
        expect(response).to have_http_status(:success)
      end

      it { is_expected.to change(Pawoo::ExpoPushToken, :count).by(-1) }
    end

    context 'given invalid parameters' do
      let(:expo_push_token_params) { { token: 'ExponentPushToken[unknown]' } }

      it 'returns http not_found' do
        subject.call
        expect(response).to have_http_status(:not_found)
      end

      it { is_expected.to_not change(Pawoo::ExpoPushToken, :count).from(1) }
    end

    context 'when parameter is missing' do
      let(:expo_push_token_params) { {} }

      it 'returns http not_found' do
        subject.call
        expect(response).to have_http_status(:not_found)
      end

      it { is_expected.to_not change(Pawoo::ExpoPushToken, :count).from(1) }
    end
  end
end
