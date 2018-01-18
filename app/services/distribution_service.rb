# frozen_string_literal: true

class DistributionService < BaseService
  # @param [Status] status
  def call(status)
    # 抽出したハッシュタグを使用するため、ProcessHashtagsServiceの後に実行されなければならない
    ProcessMentionsService.new.call(status)

    DistributionWorker.perform_async(status.id)
    Pubsubhubbub::DistributionWorker.perform_async(status.stream_entry.id)
    ActivityPub::DistributionWorker.perform_async(status.id)
    ActivityPub::ReplyDistributionWorker.perform_async(status.id) if status.reply? && status.thread.account.local?

    time_limit = TimeLimit.from_status(status)
    RemovalWorker.perform_in(time_limit.to_duration, status.id) if time_limit
  end
end
