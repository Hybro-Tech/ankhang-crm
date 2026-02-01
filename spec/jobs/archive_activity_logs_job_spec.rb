# frozen_string_literal: true

require "rails_helper"

RSpec.describe ArchiveActivityLogsJob, type: :job do
  describe "#perform" do
    let!(:old_log) { create(:activity_log, created_at: 7.months.ago) }
    let!(:recent_log) { create(:activity_log, created_at: 1.month.ago) }

    it "archives logs older than 6 months" do
      expect { described_class.new.perform }.to change(ActivityLogArchive, :count).by(1)
    end

    it "deletes archived logs from main table" do
      expect { described_class.new.perform }.to change(ActivityLog, :count).by(-1)
    end

    it "preserves recent logs" do
      described_class.new.perform
      expect(ActivityLog.find_by(id: recent_log.id)).to be_present
    end

    it "preserves original_created_at" do
      described_class.new.perform
      archive = ActivityLogArchive.last
      expect(archive.original_created_at.to_date).to eq(old_log.created_at.to_date)
    end

    it "returns archived count" do
      count = described_class.new.perform
      expect(count).to eq(1)
    end
  end
end
