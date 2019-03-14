require 'rails_helper'

RSpec.describe FirebaseCloudMessagingToken, type: :model do
  describe 'validations' do
    describe '#token' do
      it 'is uniqueness' do
        instance = Fabricate(:firebase_cloud_messaging_token)
        dupped = instance.dup
        dupped.valid?

        expect(dupped.errors).to be_added(:user_id, :taken, value: instance.user_id)
      end

      it 'is token format' do
        token = '🍺'
        instance = Fabricate.build(:firebase_cloud_messaging_token, token: token)
        instance.valid?

        expect(instance.errors).to be_added(:token, :invalid, value: token)
      end
    end
  end
end
