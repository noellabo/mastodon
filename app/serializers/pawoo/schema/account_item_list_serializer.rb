# frozen_string_literal: true

class Pawoo::Schema::AccountItemListSerializer < Pawoo::Schema::ItemListSerializer
  include RoutingHelper

  def item_list_element
    object.statuses.map.with_index(1) do |status, index|
      {
        '@type': 'ListItem',
        position: index,
        url: short_account_status_url(object.account.username, status),
      }
    end
  end
end
