# frozen_string_literal: true

require "rails_helper"

RSpec.describe ArchiveUserEventsJob, type: :job do
  describe "#perform" do
    let!(:old_event) { create(:user_event, created_at: 100.days.ago) }
    let!(:recent_event) { create(:user_event, created_at: 30.days.ago) }

    it "archives events older than 90 days" do
      expect { described_class.new.perform }.to change(UserEventArchive, :count).by(1)
    end

    it "deletes archived events from main table" do
      expect { described_class.new.perform }.to change(UserEvent, :count).by(-1)
    end

    it "preserves recent events" do
      described_class.new.perform
      expect(UserEvent.find_by(id: recent_event.id)).to be_present
    end

    it "preserves original_created_at" do
      described_class.new.perform
      archive = UserEventArchive.last
      expect(archive.original_created_at.to_date).to eq(old_event.created_at.to_date)
    end

    it "returns archived count" do
      count = described_class.new.perform
      expect(count).to eq(1)
    end
  end
end
