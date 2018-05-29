# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Api::Web::BaseController, type: :controller do
  controller do
    def create
      head 200
    end
  end

  subject do
    ActionController::Base.allow_forgery_protection = true
    post :create
  end

  it { is_expected.to have_http_status 422 }

  it 'reports CSRF error' do
    subject
    expect(body_as_json[:error]).to eq "Can't verify CSRF token authenticity."
  end
end
