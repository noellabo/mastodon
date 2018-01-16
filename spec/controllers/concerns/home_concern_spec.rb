# frozen_string_literal: true

require 'rails_helper'

describe ApplicationController, type: :controller do
  render_views

  controller do
    include HomeConcern
  end

  describe 'HEAD #index' do
    context 'when not signed in' do
      it 'redirects to about page' do
        head :index
        expect(response).to redirect_to(about_path)
      end
    end

    context 'when signed in' do
      let(:user) { Fabricate(:user) }
      subject do
        sign_in(user)
        head :index
      end

      it 'assigns @body_classes' do
        subject
        expect(assigns(:body_classes)).to eq 'app-body'
      end

      it 'assigns token' do
        app = Doorkeeper::Application.create!(name: 'Web', superapp: true, redirect_uri: Doorkeeper.configuration.native_redirect_uri)

        subject
        json = JSON.parse(assigns(:initial_state_json), symbolize_names: true)
        puts json[:meta][:access_token]
        token = Doorkeeper::AccessToken.find_by(token: json[:meta][:access_token])

        expect(token.application).to eq app
        expect(token.resource_owner_id).to eq user.id
        expect(token.scopes).to eq Doorkeeper::OAuth::Scopes.from_string('read write follow')
        expect(token.use_refresh_token?).to eq false
      end

      it 'assigns settings for {} if not available' do
        subject
        json = JSON.parse(assigns(:initial_state_json), symbolize_names: true)
        expect(json[:settings]).to eq({})
      end

      it 'assigns settings for Web::Setting if available' do
        setting = Fabricate('Web::Setting', data: '{"home":{}}', user: user)
        subject
        json = JSON.parse(assigns(:initial_state_json), symbolize_names: true)
        expect(json[:settings]).to eq setting.data
      end

      it 'assigns admin' do
        admin = Fabricate(:account)
        Setting.site_contact_username = admin.username
        subject
        json = JSON.parse(assigns(:initial_state_json), symbolize_names: true)
        expect(json[:meta][:admin]).to eq admin.id.to_s
      end

      it 'assigns streaming_api_base_url' do
        subject
        json = JSON.parse(assigns(:initial_state_json), symbolize_names: true)
        expect(json[:meta][:streaming_api_base_url]).to eq 'ws://localhost:4000'
      end
    end
  end
end
