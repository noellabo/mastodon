# == Schema Information
#
# Table name: trend_ng_words
#
#  id         :bigint(8)        not null, primary key
#  word       :string           default(""), not null
#  memo       :string           default(""), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TrendNgWord < ApplicationRecord
  validates :word, uniqueness: true, presence: true
end
