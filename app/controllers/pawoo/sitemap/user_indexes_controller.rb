# frozen_string_literal: true

class Pawoo::Sitemap::UserIndexesController < Pawoo::Sitemap::ApplicationController
  def index
    read_from_slave do
      @count = Pawoo::Sitemap::User.page_count
    end
  end

  def show
    read_from_slave do
      @accounts = Pawoo::Sitemap::User.new(params[:page]).direct_query.load
    end
  end
end
