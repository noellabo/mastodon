# frozen_string_literal: true

require 'rails_helper'

describe 'suggestion tag management for administrator', type: :feature do
  let(:user) { Fabricate(:user, admin: true) }

  before { login_as user }

  describe 'index page' do
    before do
      Fabricate(:suggestion_tag,
        order: 0,
        suggestion_type: 'comiket',
        tag: Fabricate(:tag, name: 'ZeroName'),
        description: 'Description 0.'
      )

      Fabricate(:suggestion_tag,
        order: 1,
        suggestion_type: 'normal',
        tag: Fabricate(:tag, name: 'FirstName'),
        description: 'Description 1.'
      )

      visit '/admin/suggestion_tags'
    end

    it 'shows table' do
      body = []

      all('tbody > tr').each do |tr|
        row = []
        tr.all('td').each { |data| row << data.text }
        body << row
      end

      expect(body[0][0]).to eq '0'
      expect(body[0][1]).to eq 'comiket'
      expect(body[0][2]).to eq 'ZeroName'
      expect(body[0][3]).to eq 'Description 0.'
      expect(body[1][0]).to eq '1'
      expect(body[1][1]).to eq 'normal'
      expect(body[1][2]).to eq 'FirstName'
      expect(body[1][3]).to eq 'Description 1.'
    end
  end

  describe 'new page' do
    before do
      visit '/admin/suggestion_tags/new'
    end

    it 'selects normal type by default' do
      expect(page).to have_css 'option[selected=selected][value=normal]'
    end
  end

  describe 'the page after creation failure' do
    before do
      visit '/admin/suggestion_tags/new'
      find('button[type=submit]').click
    end

    it 'flashes a failure message' do
      expect(page).to have_text '保存に失敗しました'
    end

    it 'renders new form' do
      expect(page).to have_css 'form'
    end
  end

  describe 'the page after update failure' do
    before do
      Fabricate(:suggestion_tag, id: 0)
      visit '/admin/suggestion_tags/0/edit'
      fill_in 'suggestion_tag[description]', with: ''
      find('button[type=submit]').click
    end

    it 'flashes a failure message' do
      expect(page).to have_text 'タグの更新に失敗しました'
    end

    it 'renders new form' do
      expect(page).to have_css 'form'
    end
  end
end
