# == Schema Information
#
# Table name: keyword_subscribes
#
#  id              :bigint(8)        not null, primary key
#  account_id      :bigint(8)
#  keyword         :string           not null
#  ignorecase      :boolean          default(TRUE)
#  regexp          :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  name            :string           default(""), not null
#  ignore_block    :boolean          default(FALSE)
#  disabled        :boolean          default(FALSE)
#  exclude_home    :boolean          default(FALSE)
#  exclude_keyword :string           default(""), not null
#

class KeywordSubscribe < ApplicationRecord
  belongs_to :account, inverse_of: :keyword_subscribes, required: true

  validates :keyword, presence: true
  validate :validate_subscribes_limit, on: :create
  validate :validate_keyword_regexp_syntax
  validate :validate_exclude_keyword_regexp_syntax
  validate :validate_uniqueness_in_account, on: :create

  scope :active, -> { where(disabled: false) }
  scope :home, -> { where(exclude_home: false) }
  scope :ignore_block, -> { where(ignore_block: true) }
  scope :without_local_followed, ->(account) { where.not(account: account.followers.local).where.not(account: account.subscribers.local) }

  def keyword=(val)
    super(keyword_normalization(val)) unless regexp
  end

  def exclude_keyword=(val)
    super(keyword_normalization(val)) unless regexp
  end

  def match?(text)
    keyword_regexp.match?(text) && (exclude_keyword.empty? || !exclude_keyword_regexp.match?(text))
  end

  def keyword_regexp
    to_regexp keyword
  end

  def exclude_keyword_regexp
    to_regexp exclude_keyword
  end

  class << self
    def match?(text, account_id: account_id = nil, as_ignore_block: as_ignore_block = false)
      target = KeywordSubscribe.active
      target = target.where(account_id: account_id) if account_id.present?
      target = target.ignore_block                  if as_ignore_block
      !target.find{ |t| t.match?(text) }.nil?
    end
  end

  private

  def keyword_normalization(val)
    val.to_s.strip.gsub(/\s{2,}/, ' ').split(/\s*,\s*/).reject(&:blank?).uniq.join(',')
  end

  def to_regexp(words)
    Regexp.new(regexp ? words : "(?<![#])(#{words.split(',').map do |k|
      sb = k =~ /\A[A-Za-z0-9]/ ? '\b' : k !~ /\A[\/\.]/ ? '(?<![\/\.])' : ''
      eb = k =~ /[A-Za-z0-9]\z/ ? '\b' : k !~ /[\/\.]\z/ ? '(?![\/\.])' : ''

      /(?m#{ignorecase ? 'i': ''}x:#{sb}#{Regexp.quote(k).gsub("\\ ", "[[:space:]]+")}#{eb})/
    end.join('|')})", ignorecase)
  end

  def validate_keyword_regexp_syntax
    return unless regexp

    begin
      Regexp.compile(keyword, ignorecase)
    rescue RegexpError => exception
      errors.add(:base, I18n.t('keyword_subscribes.errors.regexp', message: exception.message))
    end
  end

  def validate_exclude_keyword_regexp_syntax
    return unless regexp

    begin
      Regexp.compile(exclude_keyword, ignorecase)
    rescue RegexpError => exception
      errors.add(:base, I18n.t('keyword_subscribes.errors.regexp', message: exception.message))
    end
  end

  def validate_subscribes_limit
    errors.add(:base, I18n.t('keyword_subscribes.errors.limit')) if account.keyword_subscribes.count >= 100
  end

  def validate_uniqueness_in_account
    errors.add(:base, I18n.t('keyword_subscribes.errors.duplicate')) if account.keyword_subscribes.find_by(keyword: keyword, exclude_keyword: exclude_keyword)
  end
end
