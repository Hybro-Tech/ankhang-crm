# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActivityLog, type: :model do
  describe "associations" do
    it "belongs to user (optional)" do
      log = build(:activity_log, user: nil)
      expect(log).to be_valid
    end

    it "can reference a subject" do
      contact = create(:contact)
      log = create(:activity_log, subject: contact)
      expect(log.subject).to eq(contact)
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".by_action" do
      it "filters by action" do
        create_log = create(:activity_log, action: "create")
        update_log = create(:activity_log, action: "update")
        expect(ActivityLog.by_action("create")).to include(create_log)
        expect(ActivityLog.by_action("create")).not_to include(update_log)
      end
    end

    describe ".by_category" do
      it "filters by category" do
        contact_log = create(:activity_log, category: "contacts")
        user_log = create(:activity_log, category: "users")
        expect(ActivityLog.by_category("contacts")).to include(contact_log)
        expect(ActivityLog.by_category("contacts")).not_to include(user_log)
      end
    end

    describe ".by_user" do
      it "filters by user" do
        user_log = create(:activity_log, user: user)
        other_log = create(:activity_log)
        expect(ActivityLog.by_user(user.id)).to include(user_log)
        expect(ActivityLog.by_user(user.id)).not_to include(other_log)
      end
    end
  end

  describe "factory" do
    it "creates valid activity log" do
      log = build(:activity_log)
      expect(log).to be_valid
    end
  end
end
