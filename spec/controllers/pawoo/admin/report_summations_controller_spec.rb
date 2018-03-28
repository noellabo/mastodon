# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Admin::ReportSummationsController, type: :controller do
  describe 'GET #index' do
    it 'returns http success' do
      sign_in(Fabricate(:user, admin: true))
      get :index

      expect(response).to have_http_status(:success)
    end
  end
end
