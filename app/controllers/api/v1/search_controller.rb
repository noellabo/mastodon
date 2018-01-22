# frozen_string_literal: true

class Api::V1::SearchController < Api::BaseController
  include Authorization

  RESULTS_LIMIT = 5
  MAX_HITS_TOTAL = 10_000 # this value should be the same with index.max_result.window in ElasticSearch

  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!, only: [:statuses]

  respond_to :json

  def index
    @search = Search.new(search)
    render json: @search, serializer: REST::SearchSerializer
  end

  def statuses
    # TODO: 本リリース時（一般ユーザに全文検索機能を公開する場合）は、以下の一行を削除する。
    return forbidden unless current_user&.admin?

    query = params[:query]
    current_page = params[:page].to_i
    statuses_limit = limit_param(DEFAULT_STATUSES_LIMIT)
    return not_found if ((current_page - 1) * statuses_limit) >= MAX_HITS_TOTAL

    blocking_account_ids = current_account.blocking.pluck(:target_account_id)
    muting_account_ids = current_account.muting.pluck(:target_account_id)
    exclude_ids = (blocking_account_ids + muting_account_ids).uniq

    search_results = Status.search(query, exclude_ids).page(current_page).per(statuses_limit)
    # If no records are left after we exclude "records which exist in ES but do not in PSQL,"
    # JS gives an error. Since it is quite a rare case, we leave this issue for a while.
    @statuses = search_results.records
    @hits_total = [search_results.records.total, MAX_HITS_TOTAL].min
    render json: { statuses: @statuses, hits_total: @hits_total }, serializer: REST::SearchResultSerializer
  end

  private

  def search
    search_results.tap do |search|
      search[:statuses].keep_if do |status|
        begin
          authorize status, :show?
        rescue Mastodon::NotPermittedError
          false
        end
      end
    end
  end

  def search_results
    SearchService.new.call(
      params[:q],
      RESULTS_LIMIT,
      resolving_search?,
      current_account
    )
  end

  def resolving_search?
    params[:resolve] == 'true'
  end
end
