# frozen_string_literal: true

class Pawoo::Sitemap::PrepareStatusesWorker
  include Sidekiq::Worker
  include Pawoo::SlaveReader

  sidekiq_options queue: 'pull', unique: :until_executed

  def perform(page, continuously_key = nil)
    if continuously_key
      perform_continuously(page, continuously_key)
    # else
    #   prepare_sitemap(page)
    end
  end

  private

  def perform_continuously(page, continuously_key)
    return if page == 1 && !redis.setnx(redis_lock_key, continuously_key)
    return if page > 1 && redis.get(redis_lock_key) != continuously_key

    prepare_sitemap(page)

    next_page = page + 1
    if next_page <= page_count
      Pawoo::Sitemap::PrepareStatusesWorker.perform_async(next_page, continuously_key)
    else
      redis.del(redis_lock_key)
    end
  end

  def redis
    Redis.current
  end

  def redis_lock_key
    "pawoo:sitemap:prepare_statuses"
  end

  def prepare_sitemap(page)
    read_from_slave do
      Pawoo::Sitemap::Status.new(page).prepare
    end
  end

  def page_count
    read_from_slave do
      Pawoo::Sitemap::Status.page_count
    end
  end
end
