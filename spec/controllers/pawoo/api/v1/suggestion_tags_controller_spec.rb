require 'rails_helper'

RSpec.describe Pawoo::Api::V1::SuggestionTagsController, type: :controller do
  render_views

  describe 'GET #index' do
    context 'given invalid type' do
      subject { get :index, params: { type: 'invalid' } }
      it { is_expected.to have_http_status(:unprocessable_entity) }
    end

    context 'given limit' do
      subject { get :index, params: { limit: 1 } }

      it 'limits the number' do
        2.times.each { Fabricate(:suggestion_tag, suggestion_type: 'normal') }
        subject
        expect(body_as_json.size).to eq 1
      end
    end

    context 'given type' do
      subject { get :index, params: { type: 'comiket' } }
      it 'specifies the type' do
        comiket = Fabricate(:suggestion_tag, suggestion_type: 'comiket')
        normal = Fabricate(:suggestion_tag, suggestion_type: 'normal')

        subject

        expect(body_as_json.pluck(:name)).to include comiket.tag.name.to_s
        expect(body_as_json.pluck(:name)).not_to include normal.tag.name.to_s
      end
    end

    context 'not given type' do
      subject { get :index, params: { type: 'normal' } }
      it 'specifies normal type' do
        comiket = Fabricate(:suggestion_tag, suggestion_type: 'comiket')
        normal = Fabricate(:suggestion_tag, suggestion_type: 'normal')

        subject

        expect(body_as_json.pluck(:name)).not_to include comiket.tag.name.to_s
        expect(body_as_json.pluck(:name)).to include normal.tag.name.to_s
      end
    end

    it 'orders tags' do
      tags = 2.times.map { |order| Fabricate(:suggestion_tag, order: order) }
      get :index
      expect(body_as_json.pluck(:name)).to eq tags.map(&:tag).pluck(:name)
    end
  end
end
