# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MediaAttachment, type: :model do
  describe 'validations' do
    it 'is invalid if description has a invalid characters' do
      account = Fabricate.build(:media_attachment)
      account.description = 'జ్ఞ‌ా'
      account.valid?
      expect(account).to model_have_error_on_field(:description)
    end
  end
end
