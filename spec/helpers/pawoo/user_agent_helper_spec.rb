# frozen_string_literal: true

require 'rails_helper'

describe Pawoo::UserAgentHelper, type: :helper do
  describe 'ios_safari?' do
    subject { helper.ios_safari? }

    context 'when the user agent is Safari for iOS' do
      before { controller.request.user_agent = 'Mozilla/5.0 (iPhone; CPU iPhone OS 10_2_1 like Mac OS X) AppleWebKit/602.4.46 (KHTML, like Gecko) Version/10.0 Mobile/14D27 Safari/602.1' }
      it { is_expected.to eq true }
    end
  end
end
