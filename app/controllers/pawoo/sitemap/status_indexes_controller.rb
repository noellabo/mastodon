# frozen_string_literal: true

class Pawoo::Sitemap::StatusIndexesController < Pawoo::Sitemap::ApplicationController
  def index
    read_from_slave do
      @count = Pawoo::Sitemap::Status.page_count
    end
  end

  def show
    read_from_slave do
      sitemap = Pawoo::Sitemap::Status.new(params[:page])
      sitemap.prepare unless sitemap.cached?
      @status_pages = sitemap.query.load
    end
  end
end
