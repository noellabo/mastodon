# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Admin::GalleriesController, type: :controller do
  let(:user) { Fabricate(:user, admin: true) }

  before { sign_in user }

  describe 'POST #create' do
    context 'when params is valid' do
      subject do
        post :create, params: {
          pawoo_gallery: {
            description: 'Description',
            tag_attributes: { name: 'Name' },
          },
        }
      end

      it 'creates gallery' do
        subject

        expect(Pawoo::Gallery.joins(:tag).where(
            description: 'Description',
            tags: { name: 'name' }
          )).to exist
      end
    end

    context 'when params is invalid' do
      subject { post :create, params: { pawoo_gallery: { description: 'Description' } } }
      it { is_expected.to have_http_status :unprocessable_entity }
    end
  end

  describe 'POST #update' do
    let(:gallery) { Fabricate('Pawoo::Gallery', published: false) }

    subject do
      post :update, params: {
        id: gallery,
        pawoo_gallery: {
          published: true,
          description: 'Description',
        },
      }
    end

    it 'updates gallery' do
      subject

      gallery.reload
      expect(gallery.published).to eq true
      expect(gallery.description).to eq 'Description'
    end
  end

  describe 'DELETE #destroy' do
    let(:gallery) { Fabricate('Pawoo::Gallery', published: false) }

    it 'destroys gallery' do
      delete :destroy, params: { id: gallery }
      expect{ gallery.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
