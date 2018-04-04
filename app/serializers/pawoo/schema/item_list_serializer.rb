# frozen_string_literal: true

# Carousels  |  Search  |  Google Developers
# https://developers.google.com/search/docs/guides/mark-up-listings
class Pawoo::Schema::ItemListSerializer < ActiveModel::Serializer
  attribute :context, key: '@context'
  attribute :type, key: '@type'
  attribute :item_list_element, key: 'itemListElement'

  def context
    'http://schema.org'
  end

  def type
    'ItemList'
  end
end
