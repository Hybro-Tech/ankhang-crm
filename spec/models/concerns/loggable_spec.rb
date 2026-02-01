# frozen_string_literal: true

require "rails_helper"

RSpec.describe Loggable, type: :concern do
  # Using Team as target model (it includes Loggable)
  let(:user) { create(:user) }
  let(:team) { build(:team) }

  before do
    Current.user = user
    Current.ip_address = "127.0.0.1"
    Current.user_agent = "RSpec Test Agent"
    Current.request_id = SecureRandom.uuid
  end

  after do
    Current.reset
  end

  describe "auto-logging on create" do
    it "creates an activity log" do
      expect { team.save! }.to change(ActivityLog, :count).by(1)
    end

    it "logs with correct action format" do
      team.save!
      log = ActivityLog.last
      expect(log.action).to include("create")
      expect(log.subject).to eq(team)
      expect(log.user).to eq(user)
    end

    it "captures IP address and user agent" do
      team.save!
      log = ActivityLog.last
      expect(log.ip_address).to eq("127.0.0.1")
      expect(log.user_agent).to eq("RSpec Test Agent")
    end

    it "captures request_id" do
      team.save!
      log = ActivityLog.last
      expect(log.request_id).to be_present
    end
  end

  describe "auto-logging on update" do
    before { team.save! }

    it "creates an activity log with update action" do
      expect { team.update!(name: "Updated Name") }.to change(ActivityLog, :count).by(1)
      log = ActivityLog.last
      expect(log.action).to include("update")
    end

    it "records attribute changes" do
      team.name
      team.update!(name: "New Name")
      log = ActivityLog.last
      expect(log.record_changes).to be_present
    end
  end

  describe "auto-logging on destroy" do
    before { team.save! }

    it "creates an activity log with destroy action" do
      expect { team.destroy! }.to change(ActivityLog, :count).by(1)
      log = ActivityLog.last
      expect(log.action).to include("destroy")
    end
  end
end
