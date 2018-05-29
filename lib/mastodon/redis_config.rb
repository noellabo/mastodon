# frozen_string_literal: true

if ENV['REDIS_URL'].blank?
  password = ENV.fetch('REDIS_PASSWORD') { '' }
  host     = ENV.fetch('REDIS_HOST') { 'localhost' }
  port     = ENV.fetch('REDIS_PORT') { 6379 }
  db       = ENV.fetch('REDIS_DB') { 0 }

  ENV['REDIS_URL'] = "redis://#{password.blank? ? '' : ":#{password}@"}#{host}:#{port}/#{db}"
end

namespace = ENV.fetch('REDIS_NAMESPACE') { nil }
cache_namespace = namespace ? namespace + '_cache' : 'cache'
REDIS_CACHE_PARAMS = {
  compress: true,
  compress_threshold: 5.kilobytes, # FIXME: 本番環境で試して一番効率がよかった。疑ってかかって良い。
  expires_in: 10.minutes,
  namespace: cache_namespace,
}.freeze
