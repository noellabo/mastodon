# frozen_string_literal: true

class Pawoo::Admin::TrendNgWordsController < Admin::BaseController
  before_action :set_trend_ng_word, only: [:edit, :update, :destroy]

  def index
    @trend_ng_words = TrendNgWord.all
  end

  def new
    @trend_ng_word = TrendNgWord.new
  end

  def create
    @trend_ng_word = TrendNgWord.new(trend_ng_word_params)

    if @trend_ng_word.save
      redirect_to admin_trend_ng_words_path, notice: 'NGワードを追加しました'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @trend_ng_word.update(trend_ng_word_params)
      redirect_to admin_trend_ng_words_path, notice: 'NGワードを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @trend_ng_word.destroy
    redirect_to admin_trend_ng_words_path, notice: 'NGワードを削除しました'
  end

  private

  def set_trend_ng_word
    @trend_ng_word = TrendNgWord.find(params[:id])
  end

  def trend_ng_word_params
    params.require(:trend_ng_word).permit(:word, :memo)
  end
end
