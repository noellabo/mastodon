require 'rails_helper'

RSpec.describe Auth::OmniauthCallbacksController, type: :controller do
  render_views

  before do
    request.env['devise.mapping'] = Devise.mappings[:user]
    @request.env['omniauth.auth'] = auth
  end

  let(:auth) { OmniAuth.config.mock_auth[provider] }

  describe 'GET #pixiv' do
    subject do
      -> { get :pixiv }
    end

    let(:provider) { :pixiv }

    let(:strategy) do
      omniauth = Devise.omniauth_configs[:pixiv]
      omniauth.strategy_class.new(nil, *omniauth.args)
    end

    before do
      body = {
        "status": "success",
        "response": [],
        "count": 1,
        "pagination": {
          "previous": nil,
          "next": nil,
        }
      }

      stub_request(:get, "#{strategy.client.site}/v1/me/favorite-users.json?count=300&page=1")
        .to_return(
          status: 200,
          body: body.to_json,
          headers: { 'content-type' => 'application/json' }
        )
    end

    context 'user is signed in' do
      before do
        sign_in(user)
      end

      let!(:user) { Fabricate(:user) }

      it 'creates oauth_authentication' do
        is_expected.to change {
          user.oauth_authentications.count
        }.from(0).to(1)
      end

      it do
        controller.store_location_for(:user, settings_oauth_authentications_path)
        subject.call
        expect(response).to redirect_to(settings_oauth_authentications_path)
        expect(flash[:notice]).to be_present
      end

      context 'current_user is already linked in' do
        let!(:oauth_authentication) { Fabricate(:oauth_authentication, uid: auth.uid, provider: auth.provider, user: user) }

        it 'signed in current_user' do
          is_expected.to_not change {
            controller.current_user
          }.from(user)
        end

        it "dosen't synchronize email address" do
          is_expected.not_to change {
            controller.current_user.reload.email
          }.from(user.email)
          expect(flash[:notice]).not_to be_present
        end

        context 'current_user has initial_password_usage' do
          let(:user) { Fabricate(:user, initial_password_usage: Fabricate(:initial_password_usage)) }

          it 'synchronize email address' do
            is_expected.to change {
              user.reload.email
            }.from(user.email).to(auth['info']['email'])
            expect(flash[:notice]).to be_present
          end
        end
      end

      context 'pixiv user is already linked in' do
        let!(:oauth_authentication) { Fabricate(:oauth_authentication, uid: auth.uid, provider: auth.provider) }

        it "doesn't update oauth_authentication" do
          is_expected.to_not change {
            oauth_authentication.reload.user_id
          }.from(oauth_authentication.user_id)

          expect(flash[:alert]).to be_present
        end

        it 'signed in current_user' do
          is_expected.to_not change {
            controller.current_user
          }.from(user)
        end
      end

      context 'if user is already linked with oauth' do
        let!(:oauth_authentication) do
          Fabricate(:oauth_authentication, provider: 'pixiv', uid: 'first_uid', user: user)
        end

        it "doesn't update oauth_authentication" do
          is_expected.to_not change {
            oauth_authentication.reload.attributes
            [OauthAuthentication.count, oauth_authentication.reload[:uid]]
          }

          expect(flash[:alert]).to be_present
        end
      end

      context 'if account is already linked with other user' do
        let!(:oauth_authentication) do
          Fabricate(:oauth_authentication, provider: 'pixiv', uid: @request.env['omniauth.auth'].uid)
        end

        it 'failed updating' do
          is_expected.to_not change {
            [OauthAuthentication.count, oauth_authentication.reload.attributes]
          }

          expect(flash[:alert]).to be_present
        end
      end
    end

    context 'user is not signed in' do
      shared_examples_for 'a redis session store' do
        it 'stores auth' do
          subject.call
          cache_key = "redis_session_store:#{session.id}:devise.omniauth:auth"
          expect(Redis.current.exists(cache_key)).to be true
        end
      end

      context 'oauth is linked with user' do
        let!(:oauth_authentication) { Fabricate(:oauth_authentication, uid: auth.uid, provider: auth.provider) }

        it 'sign in linked user' do
          is_expected.to change {
            controller.current_user
          }.from(nil).to(oauth_authentication.user)
        end

        context 'enable two factor auth' do
          before do
            oauth_authentication.user.update!(otp_required_for_login: true)
          end

          it do
            subject.call
            expect(response).to render_template('auth/sessions/two_factor')
          end
        end

        context 'given other pixiv user' do
          before do
            @request.env['omniauth.auth'] = auth.merge(uid: 'new uid')
          end

          it_behaves_like 'a redis session store'

          it "doesn't sign in" do
            subject.call
            expect(response).to redirect_to(new_user_oauth_registration_path)
          end
        end
      end

      context 'oauth is not linked with user' do
        it_behaves_like 'a redis session store'

        it do
          subject.call
          expect(response).to redirect_to(new_user_oauth_registration_path)
        end
      end
    end
  end
end
