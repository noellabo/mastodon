# frozen_string_literal: true

class HomeController < ApplicationController
  include HomeConcern

  protected

  def appmode
    'default'
  end

  def default_redirect_path
    if request.path.start_with?('/web')
      new_user_session_path
    elsif single_user_mode?
      short_account_path(Account.first)
    else
      about_path
    end
  end
end
