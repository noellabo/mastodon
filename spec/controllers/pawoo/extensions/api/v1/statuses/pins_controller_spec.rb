# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::Statuses::PinsController, type: :controller do
  describe 'DELETE #destroy' do
    # キャッシュにstatus_pinsの情報も保存されているためクリアする
    it 'clears cache' do
      user = Fabricate(:user)
      pin = Fabricate(:status_pin, account: user.account)
      token = Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'write')
      Rails.cache.write pin.status.cache_key, Status.find(pin.status_id)
      sign_in user
      allow(controller).to receive(:doorkeeper_token).and_return(token)

      delete :destroy, params: { status_id: pin.status }

      expect(Rails.cache.exist?(pin.status.cache_key)).to eq false
    end
  end
end
