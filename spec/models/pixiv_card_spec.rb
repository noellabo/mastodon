require 'rails_helper'

RSpec.describe PixivCard, type: :model do
  describe 'Validations' do
    it 'requires attributes' do
      instance = described_class.new
      instance.valid?

      expect(instance.errors).to be_added(:status, :required)
      expect(instance.errors).to be_added(:url, :blank)
    end
  end
end
