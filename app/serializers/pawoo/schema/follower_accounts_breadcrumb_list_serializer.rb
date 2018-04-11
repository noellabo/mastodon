# frozen_string_literal: true

class Pawoo::Schema::FollowerAccountsBreadcrumbListSerializer < Pawoo::Schema::AccountBreadcrumbListSerializer
  include RoutingHelper

  def item_list_element
    super << {
      '@type': 'ListItem',
      item: {
        '@id': account_followers_url(object.account),
        name: I18n.t('accounts.followers'),
      },
      name: I18n.t('accounts.followers'),
      position: 2,
    }
  end
end
