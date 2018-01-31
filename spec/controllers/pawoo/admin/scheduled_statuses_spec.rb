# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Admin::ScheduledStatusesController, type: :controller do
  describe 'GET #index' do
    it 'renders scheduledStatuses' do
      sign_in(Fabricate(:user, admin: true))
      get :index

      expect(response).to have_http_status(:success)
    end
  end
end
