# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Api::V1::GalleryBlacklistedStatusesController, type: :controller do

  describe '#update' do
    subject { put :update, params: params }

    let(:params) { { gallery_tag: tagname, id: status.id } }
    let!(:gallery) { Fabricate('Pawoo::Gallery', tag: tag) }
    let(:tag) { Fabricate(:tag) }
    let(:status) { Fabricate(:status) }
    let(:tagname) { tag.name }

    context 'when current_user is not admin' do
      it { is_expected.to have_http_status :forbidden }
    end

    context 'when current_user is admin' do
      let(:user) { Fabricate(:user, admin: true) }
      before do
        allow(controller).to receive(:doorkeeper_token) do
          Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read')
        end
      end

      context 'when tagname does not exist' do
        let(:tagname) { 'hogehoge' }

        it { is_expected.to have_http_status :not_found }
      end

      context 'when tagname exists' do
        it { is_expected.to have_http_status :success }
      end
    end
  end
end
