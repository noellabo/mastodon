# frozen_string_literal: true

class Pawoo::Api::V1::GalleryBlacklistedStatusesController < Api::BaseController
  respond_to :json

  before_action :require_admin!

  def update
    @gallery = Pawoo::Gallery.joins(:tag).find_by!(tags: { name: params[:gallery_tag] })
    status = Status.find(params[:id])
    unless @gallery.gallery_blacklisted_statuses.exists?(status: status)
      @gallery.gallery_blacklisted_statuses.create!(status: status)
    end

    render_empty
  end
end
