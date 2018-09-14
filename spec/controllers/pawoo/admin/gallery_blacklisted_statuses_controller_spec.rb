# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::Admin::GalleryBlacklistedStatusesController, type: :controller do
  let(:user) { Fabricate(:user, admin: true) }

  before { sign_in user }

  describe 'DELETE #destroy' do
    context 'when params is valid' do
      it 'deletes blacklist' do
        gallery = Fabricate('Pawoo::Gallery')
        blacklist = gallery.gallery_blacklisted_statuses.create!(status: Fabricate(:status))

        delete :destroy, params: {
          gallery_id: gallery.id,
          id: blacklist.id,
        }

        expect(Pawoo::GalleryBlacklistedStatus.where(id: blacklist.id)).not_to exist
      end
    end
  end
end
