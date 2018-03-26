# frozen_string_literal: true

class Pawoo::Sitemap::ApplicationController < ApplicationController
  private

  def read_from_slave
    SwitchPoint.with_readonly(:pawoo_slave) { yield }
  end
end
