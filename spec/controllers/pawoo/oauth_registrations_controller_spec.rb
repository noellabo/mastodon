require 'rails_helper'

RSpec.describe Pawoo::OauthRegistrationsController, type: :controller do
  before do
    request.env['devise.mapping'] = Devise.mappings[:user]

    if auth
      cache_key = "redis_session_store:#{session.id}:devise.omniauth:auth"
      Redis.current.set(cache_key, auth.to_json)

      stub_request(:get, auth['info']['avatar'])
        .with(headers: { 'Referer' => "https://#{Rails.configuration.x.local_domain}" })
        .to_return(status: 200, body: File.read('spec/fixtures/files/attachment.jpg'))
    end
  end

  describe 'GET #new' do
    before do
      get :new
    end

    context 'found cache of pixiv oauth' do
      before do
        stub_request(:get, auth['info']['avatar'])
          .with(headers: { 'Referer' => "https://#{Rails.configuration.x.local_domain}" })
          .to_return(status: 200, body: File.read('spec/fixtures/files/attachment.jpg'))
      end

      let(:auth) { OmniAuth.config.mock_auth[:pixiv] }
      it { expect(response).to have_http_status(:success) }
    end

    context 'missing cache' do
      let(:auth) { nil }
      it { is_expected.to redirect_to(root_path) }
    end
  end

  describe 'POST #create' do
    subject do
      -> { post :create, params: { form_oauth_registration: attributes } }
    end

    let(:attributes) do
      {
        username: 'username'
      }
    end

    context 'found cache of pixiv oauth' do
      let(:auth) { OmniAuth.config.mock_auth[:pixiv] }

      before do
        allow(BootstrapTimelineWorker).to receive(:perform_async)
      end

      it 'creates user' do
        is_expected.to change {
          [User.count, Account.count]
        }.from([0, 0]).to([1, 1])
      end

      it 'queues up bootstrapping of home timeline' do
        subject.call
        user = User.find_by(email: auth.info.email)
        expect(BootstrapTimelineWorker).to have_received(:perform_async).with(user.account_id)
      end

      context 'when the email is duplicated' do
        let!(:unlinked_user) { Fabricate(:user, email: auth.info.email) }

        it 'redirect to login page with alert' do
          subject.call
          expect(response).to redirect_to new_user_session_path
          expect(flash[:alert]).to eq I18n.t('pawoo.oauth_registrations.already_registered')
        end
      end

      context 'when the username is duplicated' do
        let(:account) { Fabricate(:account, username: attributes[:username]) }
        let!(:unlinked_user) { Fabricate(:user, email: "other-#{auth.info.email}", account: account) }

        it 'render oauth registration page' do
          subject.call
          expect(response).to render_template(:new)
        end
      end
    end
  end
end
