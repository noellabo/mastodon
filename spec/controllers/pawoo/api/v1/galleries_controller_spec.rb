# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Api::V1::GalleriesController, type: :controller do

  describe '#show' do
    subject { get :show, params: params }

    let(:params) { { tag: tagname } }
    let!(:gallery) { Fabricate('Pawoo::Gallery', tag: tag, published: published) }
    let(:tag) { Fabricate(:tag) }
    let(:published) { true }
    let!(:statuses) do
      Fabricate.times(2, :status, tags: [tag]).each do |status|
        Fabricate(:media_attachment, status: status, file: nil)
      end
    end

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
            allow(controller).to receive(:doorkeeper_token) do
              Fabricate(:accessible_access_token, resource_owner_id: user.id, scopes: 'read')
            end
          end

          it { is_expected.to have_http_status :success }
        end
      end

      context 'when published is true' do
        it { is_expected.to have_http_status :success }

        context 'with limit parameter' do
          let(:params) { { tag: tag.name, limit: 1 } }

          it 'limits the number' do
            subject
            expect(body_as_json.size).to eq 1
          end
        end

        context 'with page parameter' do
          let(:params) { { tag: tag.name, limit: 1, max_id: statuses.map(&:id).max } }

          it 'uses a certain offset' do
            subject
            expect(body_as_json.size).to eq 1
          end

          it 'adds pagination headers if necessary' do
            subject
            expect(response.headers['Link'].find_link(['rel', 'next']).href).to eq api_v1_pawoo_gallery_url(tag.name, limit: 1, max_id: statuses.map(&:id).min)
            expect(response.headers['Link'].find_link(['rel', 'prev']).href).to eq api_v1_pawoo_gallery_url(tag.name, limit: 1, since_id: statuses.map(&:id).min)
          end
        end
      end
    end
  end
end
