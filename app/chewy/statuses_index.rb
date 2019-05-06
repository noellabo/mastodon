# frozen_string_literal: true

class StatusesIndex < Chewy::Index
  settings index: { refresh_interval: '15m' }, analysis: {
    tokenizer: {
      sudachi_tokenizer: {
        type: 'sudachi_tokenizer',
        mode: 'search',
        discard_punctuation: true,
        resources_path: '/etc/elasticsearch',
        settings_path: '/etc/elasticsearch/sudachi.json', 
      },
    },
    analyzer: {
      content: {
        filter: %w(
          lowercase
          cjk_width
          sudachi_part_of_speech
          sudachi_ja_stop
          sudachi_baseform
        ),
        tokenizer: 'sudachi_tokenizer',
        type: 'custom',
      },
    },
  }
  
  define_type ::Status.unscoped.without_reblogs.with_public_visibility.includes(:media_attachments) do
    root date_detection: false do
      field :id, type: 'long'
      field :account_id, type: 'long'

      field :text, type: 'text', value: ->(status) { [status.spoiler_text, Formatter.instance.plaintext(status)].concat(status.media_attachments.map(&:description)).join("\n\n") } do
        field :stemmed, type: 'text', analyzer: 'content'
      end
    end
  end
end
