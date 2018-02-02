require 'rails_helper'

RSpec.describe Pawoo::Api::V1::SchedulesController, type: :controller do
  render_views

  let(:user)  { Fabricate(:user, admin: true) }

  describe 'GET #index' do
    context 'without token' do
      it 'returns http unauthorized' do
        get :index
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with token' do
      context 'without read scope' do
        before do
          allow(controller).to receive(:doorkeeper_token) do
            Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: '')
          end
        end

        it 'returns http forbidden' do
          get :index
          expect(response).to have_http_status :forbidden
        end
      end

      context 'without valid resource owner' do
        before do
          token = Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read')
          user.destroy!

          allow(controller).to receive(:doorkeeper_token) { token }
        end

        it 'returns http unprocessable entity' do
          get :index
          expect(response).to have_http_status :unprocessable_entity
        end
      end

      context 'with read scope and valid resource owner' do
        before do
          allow(controller).to receive(:doorkeeper_token) do
            Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read')
          end
        end

        it 'shows only scheduled statuses' do
          posted = Fabricate(:status, account: user.account, created_at: 1.day.ago)
          scheduled = Fabricate(:status, account: user.account, created_at: 1.day.from_now)

          get :index

          expect(assigns(:statuses)).to match_array [scheduled]
        end

        it 'orders statuses by the scheduled date' do
          statuses = [2, 4].map do |number|
            Fabricate(:status, account: user.account, created_at: number.days.from_now)
          end

          get :index

          expect(assigns(:statuses)).to match_array statuses
        end

        it 'applies date contraint parameters' do
          now = DateTime.now
          statuses = [2, 4, 6].map do |number|
            Fabricate(:status, account: user.account, created_at: now + number.days)
          end

          get :index, params: { max_time: now + 5.days, since_time: now + 3.days }

          expect(assigns(:statuses)).to match_array [statuses[1]]
        end

        it 'adds pagination headers if necessary' do
          status = Fabricate(:status, account: user.account, created_at: 1.day.from_now)

          get :index, params: { limit: 1 }

          expect(response.headers['Link'].find_link(['rel', 'next']).href).to eq api_v1_schedules_url(limit: 1, since_time: status.created_at.iso8601)
          expect(response.headers['Link'].find_link(['rel', 'prev']).href).to eq api_v1_schedules_url(limit: 1, max_time: status.created_at.iso8601)
        end

        it 'does not add pagination headers if not necessary' do
          get :index

          expect(response.headers['Link']).to be_nil
        end
      end
    end
  end
end
