require 'rails_helper'

RSpec.describe Pawoo::Api::V1::FirebaseCloudMessagingTokensController, type: :controller do
  let(:user)     { Fabricate(:user, account: Fabricate(:account)) }
  let(:token)    { double acceptable?: true, resource_owner_id: user.id }

  before do
    allow(controller).to receive(:doorkeeper_token) { token }
  end

  describe 'POST #create' do
    subject do
      -> { post :create, params: { firebase_cloud_messaging_token: firebase_cloud_messaging_token } }
    end

    let(:firebase_cloud_messaging_token) do
      {
        platform: 'iOS',
        token: 'XXXX'
      }
    end

    context 'given valid parameters' do
      it 'returns http success' do
        subject.call
        expect(response).to have_http_status(:success)
      end

      it { is_expected.to change(FirebaseCloudMessagingToken, :count).by(1) }
    end

    context 'given invalid parameters' do
      let(:firebase_cloud_messaging_token) do
        super().merge(token: nil)
      end

      it 'returns http unprocessable_entity' do
        subject.call
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it { is_expected.to_not change(FirebaseCloudMessagingToken, :count).from(0) }
    end
  end


  describe 'DELETE #destroy' do
    subject do
      -> { post :destroy, params: { platform: firebase_cloud_messaging_token_params[:platform], firebase_cloud_messaging_token: firebase_cloud_messaging_token_params } }
    end

    let(:firebase_cloud_messaging_token_params) do
      {
        platform: 'iOS',
        token: 'XXXX'
      }
    end

    context 'given valid parameters' do
      let!(:firebase_cloud_messaging_token) { Fabricate(:firebase_cloud_messaging_token, firebase_cloud_messaging_token_params.merge(user: user)) }

      it 'returns http success' do
        subject.call
        expect(response).to have_http_status(:success)
      end

      it { is_expected.to change(FirebaseCloudMessagingToken, :count).by(-1) }
    end

    context 'given invalid parameters' do
      let(:firebase_cloud_messaging_token_params) do
        super().merge(token: 'unknown')
      end

      it 'returns http not_found' do
        subject.call
        expect(response).to have_http_status(:not_found)
      end

      it { is_expected.to_not change(FirebaseCloudMessagingToken, :count).from(0) }
    end
  end
end
