# frozen_string_literal: true

class Pawoo::GalleriesController < ApplicationController
  before_action :set_instance_presenter
  before_action :pawoo_set_container_classes
  before_action :set_initial_state_json

  layout 'public'

  def index
    @galleries = Pawoo::Gallery.published.order(:id)
  end

  def show
    @gallery = Pawoo::Gallery.joins(:tag).find_by!(tags: { name: params[:tag].downcase })
    if !@gallery.published? && !current_user&.admin?
      raise ActiveRecord::RecordNotFound
    end
  end

  private

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def pawoo_set_container_classes
    @pawoo_container_classes = 'container'
  end

  def set_initial_state_json
    serializable_resource = ActiveModelSerializers::SerializableResource.new(InitialStatePresenter.new(initial_state_params), serializer: InitialStateSerializer)
    @initial_state_json   = serializable_resource.to_json
  end

  def initial_state_params
    setting = current_user && Web::Setting.find_by(user: current_user)
    {
      settings: setting&.data || {},
      current_account: current_account,
      token: current_session&.token,
    }
  end
end
