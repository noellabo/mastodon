# frozen_string_literal: true
class Settings::DomainSubscribesController < Settings::BaseController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_domain_subscribes, only: :index
  before_action :set_domain_subscribe, except: [:index, :create]

  def index
    @domain_subscribe = DomainSubscribe.new
  end

  def create
    @domain_subscribe = current_account.domain_subscribes.new(domain_subscribe_params)

    if @domain_subscribe.save
      redirect_to settings_domain_subscribes_path
    else
      set_domain_subscribe

      render :index
    end
  end

  def destroy
    @domain_subscribe.destroy!
    redirect_to settings_domain_subscribes_path
  end

  private

  def set_domain_subscribe
    @domain_subscribe = current_account.domain_subscribes.find(params[:id])
  end

  def set_domain_subscribes
    @domain_subscribes = current_account.domain_subscribes.order(:updated_at).reject(&:new_record?)
  end

  def domain_subscribe_params
    params.require(:domain_subscribe).permit(:domain, :list_id)
  end
end
