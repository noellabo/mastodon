# frozen_string_literal: true

require 'rails_helper'

describe HomeController, type: :controller do
  describe 'GET #index' do
    subject { get :index }

    context 'when user has not signed in' do
      before do
        allow(controller).to receive(:root_path?).and_return(is_root_path)
      end

      context 'when path is root_path' do
        let(:is_root_path) { true }

        it 'does not store current location' do
          subject
          expect(controller.stored_location_for(:user)).to eq nil
        end

        it { is_expected.to redirect_to about_path }
      end

      context 'when path is not root_path' do
        let(:is_root_path) { false }

        it 'does not store current location' do
          subject
          expect(controller.stored_location_for(:user)).to be_present
        end

        it { is_expected.to redirect_to about_path }
      end
    end
  end
end
