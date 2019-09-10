 # frozen_string_literal: true

class REST::KeywordSubscribeSerializer < ActiveModel::Serializer
  attributes :id, :name, :keyword, :ignorecase, :regexp, :ignore_block, :disabled, :exclude_home

  belongs_to :account, serializer: REST::AccountSerializer

  def id
    object.id.to_s
  end
end
