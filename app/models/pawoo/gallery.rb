# frozen_string_literal: true
# == Schema Information
#
# Table name: pawoo_galleries
#
#  id                 :bigint(8)        not null, primary key
#  tag_id             :bigint(8)        not null
#  description        :text             default(""), not null
#  published          :boolean          default(FALSE), not null
#  image_file_name    :string
#  image_content_type :string
#  image_file_size    :integer
#  image_updated_at   :datetime
#  max_id             :bigint(8)
#  min_id             :bigint(8)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Pawoo::Gallery < ApplicationRecord
  belongs_to :tag
  has_many :gallery_blacklisted_statuses, class_name: 'Pawoo::GalleryBlacklistedStatus', foreign_key: :pawoo_gallery_id, inverse_of: :pawoo_gallery
  has_many :blacklisted_statuses, through: :gallery_blacklisted_statuses, source: :status

  has_attached_file :image
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

  validates :tag_id, uniqueness: true

  scope :published, -> { where(published: true) }

  delegate :name, to: :tag, allow_nil: true

  def tag_attributes=(value)
    tag_name = (value || {})['name']

    self.tag = Tag.find_or_initialize_by(name: tag_name.downcase) if tag_name.present?
  end

  def filtered_statuses(limit, paginate_max_id = nil, paginate_since_id = nil)
    blacklisted_status_ids = blacklisted_statuses.pluck(:id)
    paginate_max_id = max_id if max_id.present? && (paginate_max_id.nil? || paginate_max_id.to_i > max_id)
    paginate_since_id = min_id if min_id.present? && (paginate_since_id.nil? || paginate_since_id.to_i < min_id)

    scope = Status.where.not(id: blacklisted_status_ids).where(visibility: [:public, :unlisted])
                  .without_reblogs.tagged_with(tag).excluding_silenced_accounts
                  .paginate_by_max_id(limit, paginate_max_id, paginate_since_id)

    status_ids = scope.joins(:media_attachments).distinct(:id).pluck(:id)
    scope.where(id: status_ids)
  end
end
