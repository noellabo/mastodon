# frozen_string_literal: true

require 'rails_helper'

describe 'Pawoo extensions of account page', type: :feature do
  describe 'individual account page' do
    let(:account) { Fabricate(:account, domain: nil, username: 'username') }

    context 'with media requested' do
      it 'shows the link for the next media page' do
        stub_const 'AccountsController::PAWOO_STATUSES_PER_PAGE', 1
        statuses = 2.times.map { Fabricate(:status, account: account) }
        statuses.each { |status| Fabricate(:media_attachment, account: account, status: status) }

        visit '/@username/media?page=1'

        expect(page).to have_link href: 'https://cb6e6126.ngrok.io/@username/media?page=2'
      end

      it 'shows the link for the previous media page' do
        stub_const 'AccountsController::PAWOO_STATUSES_PER_PAGE', 1
        statuses = 2.times.map { Fabricate(:status, account: account) }
        statuses.each { |status| Fabricate(:media_attachment, account: account, status: status) }

        visit '/@username/media?page=2'

        expect(page).to have_link href: 'https://cb6e6126.ngrok.io/@username/media'
      end
    end

    context 'with replies requested' do
      it 'shows the link for the next reply page' do
        stub_const 'AccountsController::PAWOO_STATUSES_PER_PAGE', 1
        2.times.each { Fabricate(:status, account: account) }

        visit '/@username/with_replies?page=1'

        expect(page).to have_link href: 'https://cb6e6126.ngrok.io/@username/with_replies?page=2'
      end

      it 'shows the link for the previous reply page' do
        stub_const 'AccountsController::PAWOO_STATUSES_PER_PAGE', 1
        2.times.each { Fabricate(:status, account: account) }

        visit '/@username/with_replies?page=2'

        expect(page).to have_link href: 'https://cb6e6126.ngrok.io/@username/with_replies'
      end
    end

    it 'shows published pinned statuses as "pinned"' do
      status = Fabricate(:status, account: account, created_at: 1.day.ago, text: 'The text of the published pinned status.')
      Fabricate(:status, account: account, created_at: 1.day.ago)
      Fabricate(:status_pin, account: account, status: status)

      visit '/@username'

      entries = page.all('.entry')

      pinned = entries.select do |entry|
        entry.has_text?('The text of the published pinned status.')
      end

      expect(pinned.size).to eq 1
      expect(pinned[0]).to have_text I18n.t('stream_entries.pinned')
    end

    it 'does not show unpublished pinned statuses' do
      status = Fabricate(:status, account: account, created_at: 1.day.from_now, text: 'The text of the published pinned status.')
      Fabricate(:status, account: account, created_at: 1.day.ago)
      Fabricate(:status_pin, account: account, status: status)

      visit '/@username'

      entries = page.all('.entry')
      pinned = entries.select do |entry|
        entry.has_text?(I18n.t('stream_entries.pinned')) && entry.has_text?('The text of the published pinned status.')
      end

      expect(pinned.size).to eq 0
    end

    it 'shows published latest statuses' do
      Fabricate(:status, account: account, created_at: 1.day.ago)
      visit '/@username'
      expect(page.all('.entry').size).to eq 1
    end

    it 'does not show unpublished latest statuses' do
      Fabricate(:status, account: account, created_at: 1.day.from_now)
      visit '/@username'
      expect(page.all('.entry').size).to eq 0
    end

    it 'shows the specified page' do
      stub_const 'AccountsController::PAWOO_STATUSES_PER_PAGE', 1
      Fabricate(:status, account: account, created_at: 2.day.ago, text: 'The text of the older status.')
      Fabricate(:status, account: account, created_at: 1.day.ago, text: 'The text of the newer status.')

      visit '/@username?page=2'

      expect(page).to have_text 'The text of the older status.'
      expect(page).not_to have_text 'The text of the newer status.'
    end

    it 'shows the link for the next page' do
      stub_const 'AccountsController::PAWOO_STATUSES_PER_PAGE', 1
      2.times.each { Fabricate(:status, account: account) }

      visit '/@username?page=1'

      expect(page).to have_link href: 'https://cb6e6126.ngrok.io/@username?page=2'
    end

    it 'shows the link for the previous page' do
      stub_const 'AccountsController::PAWOO_STATUSES_PER_PAGE', 1
      3.times.each { Fabricate(:status, account: account) }

      visit '/@username?page=3'

      expect(page).to have_link href: 'https://cb6e6126.ngrok.io/@username?page=2'
    end

    it 'shows the link for the initial page if it is the second page' do
      stub_const 'AccountsController::PAWOO_STATUSES_PER_PAGE', 1
      2.times.each { Fabricate(:status, account: account) }

      visit '/@username?page=2'

      expect(page).to have_link href: 'https://cb6e6126.ngrok.io/@username'
    end
  end
end
