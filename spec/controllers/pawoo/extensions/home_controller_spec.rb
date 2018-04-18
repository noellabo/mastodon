# frozen_string_literal: true

require 'rails_helper'

describe HomeController, type: :controller do
  describe 'GET #index' do
    subject { get :index }

    context 'when user has not signed in' do
      it { is_expected.to redirect_to about_path }
    end
  end
end
