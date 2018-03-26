# frozen_string_literal: true

class Pawoo::Sitemap::StatusIndexesController < Pawoo::Sitemap::ApplicationController
  def index
    read_from_slave do
      @count = Pawoo::Sitemap::Status.page_count
    end
  end

  def show
    read_from_slave do
      @status_pages = Pawoo::Sitemap::Status.new(params[:page]).direct_query.load
    end
  end
end
