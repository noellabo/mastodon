# frozen_string_literal: true

class Pawoo::Sitemap::UserIndexesController < Pawoo::Sitemap::ApplicationController
  def index
    read_from_slave do
      @count = Pawoo::Sitemap::User.page_count
    end
  end

  def show
    page = params[:page]
    sitemap = Pawoo::Sitemap::User.new(page)

    if sitemap.cached?
      read_from_slave do
        @accounts = sitemap.query.load
      end
    else
      @accounts = []
    end
  end
end
