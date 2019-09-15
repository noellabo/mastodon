# frozen_string_literal: true

class Settings::KeywordSubscribesController < ApplicationController
  include Authorization

  layout 'admin'

  before_action :set_keyword_subscribes, only: :index
  before_action :set_keyword_subscribe, only: [:edit, :update, :destroy]
  before_action :set_body_classes

  def index
    @keyword_subscribe = KeywordSubscribe.new
  end

  def new
    @keyword_subscribe = current_account.keyword_subscribes.build
  end

  def create
    @keyword_subscribe = current_account.keyword_subscribes.build(resource_params)

    if @keyword_subscribe.save
      redirect_to settings_keyword_subscribes_path
    else
      render action: :new
    end
  end

  def edit; end

  def update
    if @keyword_subscribe.update(resource_params)
      redirect_to settings_keyword_subscribes_path
    else
      render action: :edit
    end
  end

  def destroy
    @keyword_subscribe.destroy
    redirect_to settings_keyword_subscribes_path
  end

  private

  def set_keyword_subscribes
    @keyword_subscribes = current_account.keyword_subscribes
  end

  def set_keyword_subscribe
    @keyword_subscribe = current_account.keyword_subscribes.find(params[:id])
  end

  def resource_params
    params.require(:keyword_subscribe).permit(:name, :keyword, :exclude_keyword, :ignorecase, :regexp, :ignore_block, :disabled, :exclude_home)
  end

  def set_body_classes
    @body_classes = 'admin'
  end
end
