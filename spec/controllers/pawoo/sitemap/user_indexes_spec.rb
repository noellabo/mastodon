# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Sitemap::UserIndexesController, type: :controller do
  before do
    stub_const 'Pawoo::Sitemap::SITEMAPINDEX_SIZE', 1
  end

  let!(:account) { Fabricate(:account, followers_count: 10, statuses_count: 5) }

  describe 'GET #index' do
    it 'renders sitemap' do
      get :index, format: 'xml'

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #show' do
    let(:page) { account.id }

    it 'renders sitemap' do
      get :show, params: { page: page }, format: 'xml'

      expect(response).to have_http_status(:success)
    end

    it 'assigns @account' do
      get :show, params: { page: page }, format: 'xml'

      expect(assigns(:accounts).first).to eq account
    end
  end
end
