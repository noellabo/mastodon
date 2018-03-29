# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::FollowController, type: :controller do
  describe 'POST #queue' do
    before do
      self.routes = ActionDispatch::Routing::RouteSet.new.tap do |r|
        r.draw { post 'queue' => 'pawoo/follow#queue' }
      end
    end

    subject { post :queue }

    it 'does not queue follow if no authenticity token is valid' do
      post :queue, params: { follow: 'followee' }
      expect(session).not_to have_key 'pawoo.follow'
    end

    it 'queues follow' do
      token = controller.instance_eval { form_authenticity_token }
      post :queue, params: { authenticity_token: token, follow: 'followee' }
      expect(session['pawoo.follow']).to eq 'followee'
    end

    it { is_expected.to have_http_status :success }
  end
end
