# frozen_string_literal: true
# == Schema Information
#
# Table name: pawoo_gallery_blacklisted_statuses
#
#  id               :bigint(8)        not null, primary key
#  status_id        :bigint(8)        not null
#  pawoo_gallery_id :bigint(8)        not null
#

class Pawoo::GalleryBlacklistedStatus < ApplicationRecord
  belongs_to :status
  belongs_to :pawoo_gallery, class_name: 'Pawoo::Gallery', inverse_of: :gallery_blacklisted_statuses
end
