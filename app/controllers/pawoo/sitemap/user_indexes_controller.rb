# frozen_string_literal: true

class Pawoo::Sitemap::UserIndexesController < Pawoo::Sitemap::ApplicationController
  def index
    read_from_slave do
      @count = Pawoo::Sitemap::User.page_count
    end
  end

  def show
    read_from_slave do
      sitemap = Pawoo::Sitemap::User.new(params[:page])
      sitemap.prepare unless sitemap.cached?
      @accounts = sitemap.query.load
    end
  end
end
