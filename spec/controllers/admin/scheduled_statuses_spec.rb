# frozen_string_literal: true

require 'rails_helper'

describe Admin::ScheduledStatusesController, type: :controller do
  describe 'GET #index' do
    it 'renders scheduledStatuses' do
      sign_in(Fabricate(:user, admin: true))
      get :index

      json = JSON.parse(assigns(:initial_state_json), symbolize_names: true)
      expect(json[:meta][:appmode]).to eq 'scheduledStatuses'
      expect(response).to have_http_status(:success)
    end
  end
end
