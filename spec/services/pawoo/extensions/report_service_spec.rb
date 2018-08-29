# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ReportService do
  let(:source_account) { Fabricate(:account) }
  let(:target_account) { Fabricate(:account) }

  describe 'POST #create' do
    let!(:status1) { Fabricate(:status) }
    let!(:status2) { Fabricate(:status) }
    let(:status_ids) { [status1.id, status2.id] }
    let(:pawoo_report_type) { %w[other prohibited reproduction spam].sample }

    before do
      ReportService.new.call(
        source_account,
        target_account,
        status_ids: status_ids,
        pawoo_report_type: pawoo_report_type,
        comment: 'reasons'
      )
    end

    subject { Report.find_by(comment: 'reasons') }

    context 'when the target status has not been dealt with yet' do
      it 'creates pawoo_report_targets' do
        expect(subject.pawoo_report_targets.count).to eq 2
        expect(subject.pawoo_report_targets.map(&:target)).to match_array [status1, status2]
        expect(subject.pawoo_report_targets.map(&:state)).to match ['unresolved', 'unresolved']
      end
    end

    context 'when the target status has been dealt with' do
      let(:status1) { Fabricate('Pawoo::ReportTarget', target: Fabricate(:status), state: :resolved).target }

      it 'creates pawoo_report_targets for target status that has not been dealt with yet' do
        expect(subject.pawoo_report_targets.count).to eq 1
        expect(subject.pawoo_report_targets.find_by(target: status1)).to be nil
        expect(subject.pawoo_report_targets.find_by(target: status2).state).to eq 'unresolved'
      end
    end

    context 'when pawoo_report_type is donotlike' do
      let(:pawoo_report_type) { 'donotlike' }

      it 'does not create pawoo_report_targets' do
        expect(subject.pawoo_report_targets.count).to eq 0
      end
    end

    context 'when pawoo_report_type is donotlike' do
      let(:pawoo_report_type) { 'nsfw' }
      let(:status1) { Fabricate(:status, sensitive: true) }

      it 'creates pawoo_report_targets for not sensitive status' do
        expect(subject.pawoo_report_targets.count).to eq 1
        expect(subject.pawoo_report_targets.find_by(target: status1)).to be nil
        expect(subject.pawoo_report_targets.find_by(target: status2).state).to eq 'unresolved'
      end
    end

    context 'when status_ids empty' do
      let(:status_ids) { [] }

      it 'creates a report' do
        expect(subject.action_taken).to be true
      end

      it 'creates pawoo_report_targets' do
        expect(subject.pawoo_report_targets.count).to eq 1
        expect(subject.pawoo_report_targets.first.target).to eq target_account
        expect(subject.pawoo_report_targets.first.state).to eq 'unresolved'
      end

      context 'when pawoo_report_type is donotlike' do
        let(:pawoo_report_type) { 'donotlike' }

        it 'does not create pawoo_report_targets' do
          expect(subject.pawoo_report_targets.count).to eq 0
        end
      end
    end

    it 'creates a report with specified report type' do
      expect(subject.pawoo_report_type).to eq pawoo_report_type
    end
  end
end
