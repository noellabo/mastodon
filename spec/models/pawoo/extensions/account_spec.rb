# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Account, type: :model do
  describe 'validations' do
    it 'is invalid if display_name has a invalid characters' do
      account = Fabricate.build(:account)
      account.display_name = 'జ్ఞ‌ా'
      account.valid?
      expect(account).to model_have_error_on_field(:display_name)
    end

    it 'is invalid if note has a invalid characters' do
      account = Fabricate.build(:account)
      account.note = 'జ్ఞ‌ా'
      account.valid?
      expect(account).to model_have_error_on_field(:note)
    end
  end
end
