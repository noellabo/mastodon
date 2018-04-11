# frozen_string_literal: true

class Pawoo::Schema::AccountBreadcrumbListSerializer < Pawoo::Schema::ItemListSerializer
  include RoutingHelper

  def type
    'BreadcrumbList'
  end

  def item_list_element
    [
      {
        '@type': 'ListItem',
        image: object.account.avatar? ? full_asset_url(object.account.avatar_original_url) : nil,
        item: {
          '@id': short_account_url(object.account.username),
          name: object.account.display_name? ? object.account.display_name : object.account.acct,
        },
        name: object.account.display_name? ? object.account.display_name : object.account.acct,
        position: 1,
      },
    ]
  end
end
