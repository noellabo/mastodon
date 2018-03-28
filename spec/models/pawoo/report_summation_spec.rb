require 'rails_helper'

RSpec.describe Pawoo::ReportSummation, type: :model do
  describe '.build_summation' do
    subject { Pawoo::ReportSummation.build_summation(time) }

    let(:time) { 1.day.ago.in_time_zone('Asia/Tokyo') }
    let(:log_created_at) { time + 1.second }

    let!(:other_report) { Fabricate(:report, pawoo_report_type: :other, created_at: log_created_at) }
    let!(:prohibited_report) { Fabricate(:report, pawoo_report_type: :prohibited, created_at: log_created_at) }
    let!(:reproduction_report) { Fabricate(:report, pawoo_report_type: :reproduction, created_at: log_created_at) }
    let!(:nsfw_report) { Fabricate(:report, pawoo_report_type: :nsfw, created_at: log_created_at) }
    let!(:donotlike_report1) { Fabricate(:report, pawoo_report_type: :donotlike, created_at: log_created_at) }
    let!(:donotlike_report2) { Fabricate(:report, pawoo_report_type: :donotlike, created_at: log_created_at) }
    let!(:old_report) { Fabricate(:report, pawoo_report_type: :other, created_at: 3.day.ago) }

    it { expect(subject.date).to eq time.to_date }
    it { expect(subject.total_count).to eq 6 }
    it { expect(subject.other_count).to eq 1 }
    it { expect(subject.prohibited_count).to eq 1 }
    it { expect(subject.reproduction_count).to eq 1 }
    it { expect(subject.spam_count).to eq 0 }
    it { expect(subject.nsfw_count).to eq 1 }
    it { expect(subject.donotlike_count).to eq 2 }
  end
end
