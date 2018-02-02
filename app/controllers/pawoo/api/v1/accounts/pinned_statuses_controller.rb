# frozen_string_literal: true

class Pawoo::Api::V1::Accounts::PinnedStatusesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :set_account

  respond_to :json

  def index
    limit = limit_param(DEFAULT_STATUSES_LIMIT)

    statuses = @account.pinned_statuses.merge(StatusPin.recent.paginate_by_max_id(limit, params[:max_id], params[:since_id]))

    @statuses = cache_collection(statuses, Status)

    next_path = api_v1_account_pinned_statuses_url(pagination_params(max_id: @statuses.last.status_pin.id)) if @statuses.size == limit
    prev_path = api_v1_account_pinned_statuses_url(pagination_params(since_id: @statuses.first.status_pin.id)) unless @statuses.empty?

    set_pagination_headers(next_path, prev_path)

    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end

  def set_account
    @account = Account.find(params[:account_id])
  end
end
