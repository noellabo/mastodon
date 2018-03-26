# frozen_string_literal: true

class Pawoo::Sitemap::ApplicationController < ApplicationController
  include Pawoo::Sitemap

  before_action :set_page, only: :show

  private

  def read_from_slave
    SwitchPoint.with_readonly(:pawoo_slave) { yield }
  end

  def set_page
    @page = params[:page]
  end
end
