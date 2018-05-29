# == Schema Information
#
# Table name: suggestion_tags
#
#  id              :bigint(8)        not null, primary key
#  order           :integer          default(1), not null
#  description     :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  suggestion_type :integer          default("normal"), not null
#  tag_id          :bigint(8)        not null
#

class SuggestionTag < ApplicationRecord
  belongs_to :tag, required: true

  validates :order, :description, presence: true
  validates :tag_id, uniqueness: { scope: :suggestion_type }

  enum suggestion_type: { normal: 0, comiket: 1 }

  delegate :name, to: :tag, allow_nil: true

  def tag_attributes=(value)
    tag_name = (value || {})['name']
    self.tag = Tag.find_or_initialize_by(name: tag_name)
  end
end
