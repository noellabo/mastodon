require 'rails_helper'

describe Pawoo::Api::V1::FollowersYouFollowController, type: :controller do
  let(:user)  { Fabricate(:user, account: Fabricate(:account, username: 'alice')) }
  let(:target_account) { Fabricate(:account) }

  describe '#show' do
    subject { get :show, params: { account_id: account_id } }

    context 'without token' do
      let(:account_id) { target_account.id }
      it { is_expected.to have_http_status :unauthorized }
    end

    context 'with token' do
      before do
        allow(controller).to receive(:doorkeeper_token) do
          Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read')
        end
      end

      context 'given invalid account id' do
        let(:account_id) { -1 }
        it { is_expected.to have_http_status :not_found }
      end

      context 'given valid account id' do
        let(:account_id) { target_account.id }
        it { is_expected.to have_http_status :ok }
      end

      context 'get correct accounts' do
        before do
          accounts = 3.times.map{ Fabricate(:account) }
          accounts.each do |account|
            account.follow!(target_account)
            user.account.follow!(account)
          end
        end
        let(:account_id) { target_account.id }
        it do
          subject
          expect(body_as_json.size).to eq 3
        end
      end
    end
  end
end
