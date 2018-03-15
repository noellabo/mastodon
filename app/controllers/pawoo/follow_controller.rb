# frozen_string_literal: true

class Pawoo::FollowController < ActionController::Base
  def queue
    session['pawoo.follow'] = params[:follow] if any_authenticity_token_valid?
    head 200
  end
end
