# frozen_string_literal: true

class Pawoo::Sitemap::StatusIndexesController < Pawoo::Sitemap::ApplicationController
  def index
    read_from_slave do
      @count = Pawoo::Sitemap::Status.page_count
    end
  end

  def show
    page = params[:page]
    sitemap = Pawoo::Sitemap::Status.new(page)

    if sitemap.cached?
      read_from_slave do
        @status_pages = sitemap.query.load
      end
    else
      Pawoo::Sitemap::PrepareStatusesWorker.perform_async(page)
      @status_pages = []
    end
  end
end
