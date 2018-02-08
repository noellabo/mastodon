require 'rails_helper'

RSpec.describe Pawoo::OauthRegistrationsController, type: :controller do
  let(:auth) { OmniAuth.config.mock_auth[:pixiv] }
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  def cache
    cache_key = "redis_session_store:#{session.id}:devise.omniauth:auth"
    Redis.current.set(cache_key, auth.to_json)

    stub_request(:get, auth['info']['avatar'])
      .with(headers: { 'Referer' => "https://#{Rails.configuration.x.local_domain}" })
      .to_return(status: 200, body: File.read('spec/fixtures/files/attachment.jpg'))
  end

  shared_examples 'cache miss' do
    context 'missing cache' do
      it { is_expected.to redirect_to(root_path) }

      it 'alerts cache miss' do
        subject
        expect(flash[:alert]).to eq I18n.t('devise.failure.timeout')
      end
    end
  end

  describe 'GET #new' do
    subject { get :new }

    context 'hit cache of pixiv oauth' do
      before { cache }
      it { is_expected.to have_http_status(:success) }
    end

    include_examples 'cache miss'
  end

  describe 'POST #create' do
    subject { post :create, params: { form_oauth_registration: attributes } }
    let(:attributes) { { username: 'username' } }

    context 'hit cache of pixiv oauth' do
      before do
        cache
        allow(BootstrapTimelineWorker).to receive(:perform_async)
      end

      it 'creates user' do
        subject
        expect(Account.joins(:user).where(attributes)).to exist
      end

      it 'queues up bootstrapping of home timeline' do
        subject
        user = User.find_by(email: auth.info.email)
        expect(BootstrapTimelineWorker).to have_received(:perform_async).with(user.account_id)
      end

      context 'when the email is duplicated' do
        let!(:unlinked_user) { Fabricate(:user, email: auth.info.email) }

        it { is_expected.to redirect_to new_user_session_path }

        it 'makes alert' do
          subject
          expect(flash[:alert]).to eq I18n.t('pawoo.oauth_registrations.already_registered')
        end
      end

      context 'when the username is duplicated' do
        let(:account) { Fabricate(:account, username: attributes[:username]) }
        let!(:unlinked_user) { Fabricate(:user, email: "other-#{auth.info.email}", account: account) }

        it { is_expected.to render_template(:new) }
      end
    end

    include_examples 'cache miss'
  end
end
