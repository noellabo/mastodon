# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Admin::SuggestionTagsController, type: :controller do
  let(:user) { Fabricate(:user, admin: true) }

  before { sign_in user }

  describe 'POST #create' do
    context 'with suggestion_tag' do
      context 'when suggestion_tag is valid' do
        subject do
          post :create, params: {
            suggestion_tag: {
              order: 42,
              description: 'Description',
              suggestion_type: 'comiket',
              tag_attributes: { name: 'Name' },
            },
          }
        end

        it 'creates suggestion tag' do
          subject

          expect(SuggestionTag.joins(:tag).where(
            order: 42,
            description: 'Description',
            suggestion_type: 'comiket',
            tags: { name: 'Name' }
          )).to exist
        end

        it { is_expected.to redirect_to '/admin/suggestion_tags' }

        it 'flashes success message' do
          subject
          expect(flash[:notice]).to eq 'タグを作成しました'
        end
      end

      context 'when suggestion_tag is invalid' do
        subject { post :create, params: { suggestion_tag: { order: 42 } } }
        it { is_expected.to have_http_status :unprocessable_entity }
      end
    end

    context 'without suggestion_tag' do
      subject { post :create }

      it 'raises error ActionController::ParameterMissing' do
        expect{ subject }.to raise_error ActionController::ParameterMissing
      end
    end
  end

  describe 'POST #update' do
    let(:suggestion) { Fabricate(:suggestion_tag) }

    context 'with suggestion_tag' do
      subject do
        post :update, params: {
          id: suggestion,
          suggestion_tag: {
            order: 42,
            description: 'Description',
            suggestion_type: 'comiket',
          },
        }
      end

      context 'with suggestion tag which can be updated' do
        it 'updates suggestion tag' do
          subject

          suggestion.reload
          expect(suggestion.order).to eq 42
          expect(suggestion.description).to eq 'Description'
          expect(suggestion.suggestion_type).to eq 'comiket'
        end

        it { is_expected.to redirect_to '/admin/suggestion_tags' }

        it 'flashes error message' do
          subject
          expect(flash[:notice]).to eq 'タグを更新しました'
        end
      end

      context 'with suggestion tag which cannot be updated' do
        before do
          allow_any_instance_of(SuggestionTag).to receive(:update).and_return(false)
        end

        it { is_expected.to have_http_status :unprocessable_entity }
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:suggestion) { Fabricate(:suggestion_tag) }

    it 'destroys suggestion tag' do
      delete :destroy, params: { id: suggestion }
      expect{ suggestion.reload }.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
