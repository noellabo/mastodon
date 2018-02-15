# frozen_string_literal: true

require 'rails_helper'

describe HomeController, type: :controller do
  describe 'GET #index' do
    subject { get :index }

    context 'when user has not signed in' do
      context 'if the request path matches with tag path' do
        before { request.path = '/web/timelines/tag/name' }
        it { is_expected.to redirect_to '/tags/name' }
      end

      it { is_expected.to redirect_to about_path }
    end
  end
end
