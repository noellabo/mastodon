# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Timelines::HomeController, type: :controller do
  describe 'GET #show' do
    it 'limits ID range by max_id parameter' do
      user = Fabricate(:user)
      token = Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read')
      Fabricate(:status, account: user.account, created_at: 1.year.ago)
      allow(controller).to receive(:doorkeeper_token) { token }

      get :show, params: { max_id: Mastodon::Snowflake.id_at(Time.now) }

      expect(body_as_json).to be_empty
    end
  end
end
