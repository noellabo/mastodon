# frozen_string_literal: true

class Pawoo::Admin::GalleriesController < Admin::BaseController
  before_action :set_gallery, only: [:show, :edit, :update, :destroy]

  def index
    @galleries = Pawoo::Gallery.order(:id)
  end

  def new
    @gallery = Pawoo::Gallery.new
    @gallery.build_tag
  end

  def create
    @gallery = Pawoo::Gallery.new(gallery_params)

    if @gallery.save
      redirect_to admin_pawoo_gallery_url(@gallery), notice: 'ギャラリーを追加しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @gallery_blacklisted_statuses = @gallery.gallery_blacklisted_statuses.preload(:status)
  end

  def edit; end

  def update
    if @gallery.update(gallery_params_for_update)
      redirect_to admin_pawoo_gallery_url(@gallery), notice: 'ギャラリーを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @gallery.destroy
    redirect_to admin_pawoo_galleries_url, notice: 'ギャラリーを削除しました'
  end

  private

  def set_gallery
    @gallery = Pawoo::Gallery.find(params[:id])
  end

  def gallery_params
    params.require(:pawoo_gallery).permit(:image, :description, :max_id, :min_id, :published, tag_attributes: [:name])
  end

  def gallery_params_for_update
    params.require(:pawoo_gallery).permit(:image, :description, :max_id, :min_id, :published)
  end
end
