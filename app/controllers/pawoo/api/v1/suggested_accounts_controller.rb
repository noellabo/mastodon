# frozen_string_literal: true

class Pawoo::Api::V1::SuggestedAccountsController < Api::BaseController
  before_action -> { doorkeeper_authorize! :follow }
  before_action :require_user!

  respond_to :json

  def index
    limit = limit_param(15)
    page = params[:page].to_i
    seed = params[:seed] ? params[:seed].to_i : Random.new_seed

    query = suggested_accounts(current_user.account)
      .shuffle(seed)
      .per(limit)
      .page(params[:page])

    @accounts = query.all

    # 巨大なoffsetに対応できるか不明なので、50ページまでしか対応しない
    next_path = api_v1_suggested_accounts_url(seed: seed, page: page + 1) if page < 50 && @accounts.present?
    prev_path = api_v1_suggested_accounts_url(seed: seed, page: page - 1) if page.positive?
    set_pagination_headers(next_path, prev_path)

    render json: @accounts, each_serializer: REST::SuggestedAccountSerializer
  end

  private

  def triadic_closures_accounts
    limit = 4
    offset = params[:page].to_i * limit
    Account.triadic_closures(current_account, offset: offset, limit: limit)
  end

  def suggested_accounts(account)
    following = account.following.ids
    muted_and_blocked = account.excluded_from_timeline_account_ids
    oauth_authentication = account.oauth_authentications.find_by(provider: 'pixiv')

    SuggestedAccountQuery.new
      .exclude_ids([account.id] + following + muted_and_blocked)
      .with_pixiv_follows(oauth_authentication, limit: 6)
      .with_tradic(account, limit: 6)
  end
end
