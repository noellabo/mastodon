# frozen_string_literal: true

class Pawoo::Admin::GalleryBlacklistedStatusesController < Admin::BaseController
  before_action :set_gallery, only: [:destroy]

  def destroy
    gallery_blacklisted_status = @gallery.gallery_blacklisted_statuses.find(params[:id])
    gallery_blacklisted_status.destroy!

    redirect_to admin_pawoo_gallery_url(@gallery), notice: 'ブラックリストから削除しました'
  end

  private

  def set_gallery
    @gallery = Pawoo::Gallery.find(params[:gallery_id])
  end
end
