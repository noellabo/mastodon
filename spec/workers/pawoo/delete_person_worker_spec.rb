# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::DeletePersonWorker do
  describe 'perform' do
    subject { described_class.new.perform(account.id) }

    let!(:account) { Fabricate(:account) }

    shared_examples 'prepares sitemap' do
      it { expect { subject }.not_to raise_error }
      it 'delete account' do
        subject
        expect(Account.where(id: account.id)).to be_nil
      end
    end
  end
end
