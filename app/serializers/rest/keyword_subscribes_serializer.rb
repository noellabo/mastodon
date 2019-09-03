 # frozen_string_literal: true

class REST::KeywordSubscribeSerializer < ActiveModel::Serializer
  attributes :id, :keyword, :ignorecase, :regexp

  belongs_to :account, serializer: REST::AccountSerializer

  def id
    object.id.to_s
  end
end
