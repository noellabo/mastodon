# frozen_string_literal: true

module HomeConcern
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
    before_action :set_initial_state_json
  end

  def index
    @body_classes = 'app-body'
  end

  private

  def find_redirect_path_from_request
    return account_path(Account.first) if single_user_mode?

    case request.path
    when %r{\A/web/statuses/(?<status_id>\d+)\z}
      status_id = Regexp.last_match[:status_id]
      status = Status.where(visibility: [:public, :unlisted]).find_by(id: status_id)
      return short_account_status_path(status.account, status) if status && status.local?
    when %r{\A/web/accounts/(?<account_id>\d+)\z}
      account_id = Regexp.last_match[:account_id]
      account = Account.find_by(id: account_id)
      return short_account_path(account) if account && account.local?
    when %r{\A/web/timelines/tag/(?<tag>.+)\z}
      return tag_path(URI.decode(Regexp.last_match[:tag]))
    end
    about_path
  end

  def authenticate_user!
    redirect_to(find_redirect_path_from_request) unless user_signed_in?
  end

  def set_initial_state_json
    serializable_resource = ActiveModelSerializers::SerializableResource.new(InitialStatePresenter.new(initial_state_params), serializer: InitialStateSerializer)
    @initial_state_json   = serializable_resource.to_json
  end

  def initial_state_params
    {
      settings: Web::Setting.find_by(user: current_user)&.data || {},
      push_subscription: current_account.user.web_push_subscription(current_session),
      current_account: current_account,
      token: current_session.token,
      admin: Account.find_local(Setting.site_contact_username),
      appmode: appmode,
    }
  end

  # NOTE: Override me
  def appmode; end
end
