# frozen_string_literal: true

class Pawoo::Schema::FollowingAccountsBreadcrumbListSerializer < Pawoo::Schema::AccountBreadcrumbListSerializer
  include RoutingHelper

  def item_list_element
    super << {
      '@type': 'ListItem',
      item: {
        '@id': account_following_index_url(object.account),
        name: I18n.t('accounts.following'),
      },
      name: I18n.t('accounts.following'),
      position: 2,
    }
  end
end
