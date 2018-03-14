# frozen_string_literal: true

require 'rails_helper'

describe AccountsController, type: :controller do
  describe 'pawoo_suggestion_strip_props' do
    it 'sets locale' do
      expect(controller.view_context.pawoo_suggestion_strip_props[:locale]).to eq :en
    end

    it 'sets accounts' do
      account = Fabricate(:account)
      Redis.current.sadd('pawoo:publicly_suggested_accounts', account.id)

      expect(controller.view_context.pawoo_suggestion_strip_props[:accounts].pluck(:id)).to include account.id.to_s
    end

    it 'sets tags' do
      tag = Fabricate(:tag, name: 'name')
      Fabricate(:suggestion_tag, tag: tag, description: 'description', suggestion_type: :normal)

      expect(controller.view_context.pawoo_suggestion_strip_props[:tags]).to eq [
        {
          name: 'name',
          url: 'https://cb6e6126.ngrok.io/tags/name',
          type: 'suggestion',
          description: 'description',
        },
      ]
    end
  end
end
