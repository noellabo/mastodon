# frozen_string_literal: true

class Pawoo::RefreshSitemapStatusesWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'pull'

  def perform(page)
    Pawoo::RefreshSitemapStatusesService.new.call(page)
  end
end
