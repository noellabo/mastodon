# See https://github.com/elastic/elasticsearch-rails/issues/481
require 'typhoeus'
require 'typhoeus/adapters/faraday'

Elasticsearch::Model.client = Elasticsearch::Client.new(
  hosts: [
    {
      host: ENV['ELASTICSEARCH_HOST'] || '192.168.42.1',
      port: ENV['ELASTICSEARCH_PORT'] || '9200',
    }
  ]
)
