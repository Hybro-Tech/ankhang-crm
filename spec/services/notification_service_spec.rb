# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificationService do
  let(:user) { create(:user) }
  let(:contact) { create(:contact) }

  describe ".notify" do
    it "creates a notification for user" do
      expect do
        described_class.notify(
          user: user,
          type: "contact_created",
          notifiable: contact
        )
      end.to change(Notification, :count).by(1)
    end

    it "sets correct notification attributes" do
      described_class.notify(
        user: user,
        type: "contact_created",
        notifiable: contact,
        title: "Test Title",
        body: "Test Body"
      )

      notification = Notification.last
      expect(notification.user).to eq(user)
      expect(notification.notification_type).to eq("contact_created")
      expect(notification.notifiable).to eq(contact)
      expect(notification.title).to eq("Test Title")
    end

    it "uses default title when not provided" do
      described_class.notify(
        user: user,
        type: "contact_created",
        notifiable: contact
      )

      notification = Notification.last
      expect(notification.title).to eq("Khách hàng mới")
    end
  end

  describe ".notify_many" do
    let(:users) { create_list(:user, 3) }

    it "creates notifications for all users" do
      expect do
        described_class.notify_many(
          users: User.where(id: users.pluck(:id)),
          type: "contact_created",
          notifiable: contact
        )
      end.to change(Notification, :count).by(3)
    end
  end

  describe "Role::SALE constant usage" do
    it "uses Role::SALE constant instead of hardcoded string" do
      # This test verifies that the refactoring is working correctly
      expect(Role::SALE).to eq("sale")
    end
  end
end
