# frozen_string_literal: true

class FeedInsertWorker
  include Sidekiq::Worker

  def perform(status_id, ids, type = :home)
    @type     = type.to_sym
    @status   = Status.find(status_id)

    case @type
    when :home
      @followers = Account.where(id: ids)
    when :list
      @lists     = List.where(id: ids).preload(:account)
      @followers = @lists.map(&:account)
    end

    check_and_insert
  rescue ActiveRecord::RecordNotFound
    true
  end

  private

  def check_and_insert
    # TODO: reduce N+1 queries to filter followers
    @followers = @followers.reject { |follower| feed_filtered?(follower) }

    perform_push if @followers.present?
  end

  def feed_filtered?(follower)
    # Note: Lists are a variation of home, so the filtering rules
    # of home apply to both
    FeedManager.instance.filter?(:home, @status, follower.id)
  end

  def perform_push
    case @type
    when :home
      FeedManager.instance.push_to_home(@followers, @status)
    when :list
      @lists = @lists.select { |list| @followers.include? list.account }
      FeedManager.instance.push_to_list(@lists, @status)
    end
  end
end
