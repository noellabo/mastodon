# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::SearchController, type: :controller do
  describe 'GET #statuses' do
    let(:token) { Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read') }

    before do
      allow(controller).to receive(:doorkeeper_token) { token }
      sign_in user
    end

    context 'with administrator' do
      let(:user) { Fabricate(:user, admin: true) }

      context 'if the specified page is out of range' do
        subject { get :statuses, params: { page: 501, query: 'query' } }
        it { is_expected.to have_http_status :not_found }
      end

      it 'excludes statuses made by blocked accounts' do
        block = Fabricate(:block, account: user.account)
        search = Status.method(:search)

        expect(Status).to receive(:search) do |*args|
          expect(args).to eq ['query', [block.target_account_id]]
          search.call *args
        end

        get :statuses, params: { query: 'query' }
      end

      it 'excludes statuses made by muted accounts' do
        mute = Fabricate(:mute, account: user.account)
        search = Status.method(:search)

        expect(Status).to receive(:search) do |*args|
          expect(args).to eq ['query', [mute.target_account_id]]
          search.call *args
        end

        get :statuses, params: { query: 'query' }
      end

      it 'returns total number of results' do
        allow_any_instance_of(Elasticsearch::Model::Response::Records).to receive(:total).and_return(10_000)
        get :statuses, params: { query: 'query' }
        expect(body_as_json[:hits_total]).to eq 10_000
      end

      it 'limits total number of results' do
        allow_any_instance_of(Elasticsearch::Model::Response::Records).to receive(:total).and_return(10_001)
        get :statuses, params: { query: 'query' }
        expect(body_as_json[:hits_total]).to eq 10_000
      end
    end

    context 'with user who is not administrator' do
      let(:user) { Fabricate(:user, admin: false) }
      subject { get :statuses, params: { query: 'query' } }
      it { is_expected.to have_http_status :forbidden }
    end
  end
end
