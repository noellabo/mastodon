# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::GalleriesController, type: :controller do

  describe '#show' do
    subject { get :show, params: params }

    let(:params) { { tag: tagname } }
    let!(:gallery) { Fabricate('Pawoo::Gallery', tag: tag, published: published) }
    let(:tag) { Fabricate(:tag) }
    let(:published) { true }

    context 'when tagname does not exist' do
      let(:tagname) { 'hogehoge' }

      it { is_expected.to have_http_status :not_found }
    end

    context 'when tagname exists' do
      let(:tagname) { tag.name }

      context 'when published is false' do
        let(:published) { false }

        context 'when current_user is not admin' do
          it { is_expected.to have_http_status :not_found }
        end

        context 'when current_user is admin' do
          let(:user) { Fabricate(:user, admin: true) }

          before do
            sign_in user, scope: :user
          end

          it { is_expected.to have_http_status :success }
        end
      end

      context 'when published is true' do
        it { is_expected.to have_http_status :success }
      end
    end
  end
end
