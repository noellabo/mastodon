require 'rails_helper'

describe Pawoo::RefreshPopularAccountService do
  describe '.call' do
    subject do
      -> { Pawoo::RefreshPopularAccountService.new.call }
    end
    let(:accounts) { [popular_account_on_pawoo, popular_account_on_pixiv, normal_account, inactive_account] }
    let(:popular_account_on_pawoo) { Fabricate(:account) }
    let(:popular_account_on_pixiv) { Fabricate(:account) }
    let(:normal_account) { Fabricate(:account) }
    let(:inactive_account) { Fabricate(:account) }

    def prepare_popular_account_on_pawoo
      status = Fabricate(:status, account: popular_account_on_pawoo)
      Fabricate(:media_attachment, account: popular_account_on_pawoo, status: status, created_at: status.created_at)
      Fabricate.times(3, :favourite, status: status)
      Fabricate.times(3, :status, reblog: status)
    end

    def prepare_popular_account_on_pixiv
      Fabricate(:oauth_authentication, user: Fabricate(:user, account: popular_account_on_pixiv), uid: 123)
      status = Fabricate(:status, account: popular_account_on_pixiv)
      Fabricate.times(5, :pixiv_follow, target_pixiv_uid: 123)
    end

    def prepare_normal_account
      status = Fabricate(:status, account: normal_account)
      Fabricate(:media_attachment, account: normal_account, status: status, created_at: status.created_at)
    end

    def prepare_inactive_account
      status = Fabricate(:status, account: inactive_account, created_at: 2.month.ago)
      Fabricate(:media_attachment, account: inactive_account, status: status, created_at: status.created_at)
      Fabricate.times(3, :favourite, status: status)
      Fabricate.times(3, :status, reblog: status)
    end

    def popular_account_scores
      Redis.current.zrevrange(Pawoo::RefreshPopularAccountService::REDIS_KEY, 0, -1, withscores: true).to_h
    end

    before do
      stub_const 'Pawoo::RefreshPopularAccountService::MIN_SCORE', 3
      prepare_popular_account_on_pawoo
      prepare_popular_account_on_pixiv
      prepare_normal_account
      prepare_inactive_account

      Redis.current.zadd(Pawoo::RefreshPopularAccountService::REDIS_KEY, accounts.map { |account| [4, account.id] })
    end

    it 'refreshes popular accounts' do
      is_expected.to change { popular_account_scores }.from(accounts.map { |account| [account.id.to_s, 4.to_f] }.to_h).to({
        "#{popular_account_on_pawoo.id}" => 6.to_f,
        "#{popular_account_on_pixiv.id}" => 5.to_f,
      })
    end
  end
end
