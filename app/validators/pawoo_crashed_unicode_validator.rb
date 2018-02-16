# frozen_string_literal: true

class PawooCrashedUnicodeValidator < ActiveModel::EachValidator
  CRASHED_UNICODE = 'జ్ఞ‌ా'

  def validate_each(record, attribute, value)
    record.errors.add(attribute, I18n.t('pawoo.validations.crashed_unicode')) if include_crashed_unicode?(value)
  end

  private

  def include_crashed_unicode?(text)
    text&.include? CRASHED_UNICODE
  end
end
