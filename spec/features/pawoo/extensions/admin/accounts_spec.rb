# frozen_string_literal: true

require 'rails_helper'

describe 'accounts management for administrator', type: :feature do
  let(:user) { Fabricate(:user, admin: true) }

  before { login_as user }

  describe 'account page' do
     let!(:moderated_user) { Fabricate(:user, account: Fabricate(:account, id: 0)) }

     context 'when the account is linked to OAuth provider' do
       subject do
         Fabricate(:oauth_authentication, user: moderated_user)
         visit '/admin/accounts/0'
         page
       end

       it { is_expected.to have_text I18n.t('admin.oauth_authentications.linked') }
     end

     context 'when the account is not linked to OAuth provider' do
       subject do
         visit '/admin/accounts/0'
         page
       end

       it { is_expected.to have_text I18n.t('admin.oauth_authentications.not_linked') }
     end
  end
end
