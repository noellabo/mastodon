# frozen_string_literal: true

class Pawoo::Schema::StatusBreadcrumbListSerializer < Pawoo::Schema::AccountBreadcrumbListSerializer
  include RoutingHelper

  def item_list_element
    images = object.status.media_attachments.where(type: :image).map do |media_attachment|
      full_asset_url media_attachment.file
    end

    super << {
      '@type': 'ListItem',
      image: images.first,

      # Article  |  Search  |  Google Developers
      # https://developers.google.com/search/docs/data-types/article
      item: {
        '@id': short_account_status_url(object.account.username, object.status),
        '@type': 'Article',
        url: short_account_status_url(object.account.username, object.status),
        name: object.status.title,
        image: images,
      },

      name: object.status.title,
      position: 2,
    }
  end
end
