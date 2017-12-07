# frozen_string_literal: true

class Api::V1::SchedulesController < Api::BaseController
  before_action -> { doorkeeper_authorize! :read }
  before_action :require_user!

  # index statuses on account_id and created_at when releasing this feature for
  # public.
  before_action :require_admin!

  after_action :insert_pagination_headers

  respond_to :json

  def index
    @statuses = load_statuses
    render json: @statuses, each_serializer: REST::StatusSerializer, relationships: StatusRelationshipsPresenter.new(@statuses, current_user&.account_id)
  end

  private

  def load_statuses
    cache_collection(results, Status)
  end

  def results
    return @_results if @_results.present?

    max_time = params[:max_time]
    since_time = params[:since_time]

    query = current_account.statuses
                          .scheduled
                          .reorder(:created_at)
                          .limit(limit_param(DEFAULT_STATUSES_LIMIT))

    query = query.where("statuses.created_at < ? AT TIME ZONE 'UTC'", max_time) if max_time.present?
    query = query.where("statuses.created_at > ? AT TIME ZONE 'UTC'", since_time) if since_time.present?

    @_results = query
  end

  def insert_pagination_headers
    set_pagination_headers(next_path, prev_path)
  end

  def next_path
    if records_continue?
      api_v1_schedules_url pagination_params(since_time: pagination_since_time.iso8601)
    end
  end

  def prev_path
    unless results.empty?
      api_v1_schedules_url pagination_params(max_time: pagination_max_time.iso8601)
    end
  end

  def pagination_max_time
    results.last.created_at
  end

  def pagination_since_time
    results.first.created_at
  end

  def records_continue?
    results.size == limit_param(DEFAULT_STATUSES_LIMIT)
  end

  def pagination_params(core_params)
    params.permit(:limit).merge(core_params)
  end
end
