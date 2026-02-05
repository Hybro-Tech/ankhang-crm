# frozen_string_literal: true

require "rails_helper"

RSpec.describe WebPushService do
  let(:user) { create(:user) }
  let(:contact) { create(:contact) }

  # Shared VAPID mock config
  let(:valid_vapid_config) do
    {
      public_key: "test_public_key_12345",
      private_key: "test_private_key_67890",
      subject: "mailto:test@example.com"
    }
  end

  describe ".vapid_configured?" do
    context "when VAPID keys are configured" do
      before do
        allow(Rails.application.config.x).to receive(:vapid).and_return(valid_vapid_config)
      end

      it "returns true" do
        expect(described_class.send(:vapid_configured?)).to be true
      end
    end

    context "when VAPID keys are not configured" do
      before do
        allow(Rails.application.config.x).to receive(:vapid).and_return(nil)
      end

      it "returns false" do
        expect(described_class.send(:vapid_configured?)).to be false
      end
    end

    context "when VAPID keys are empty" do
      before do
        empty_config = { public_key: "", private_key: "" }
        allow(Rails.application.config.x).to receive(:vapid).and_return(empty_config)
      end

      it "returns false" do
        expect(described_class.send(:vapid_configured?)).to be false
      end
    end
  end

  describe ".notify_user" do
    context "when VAPID is not configured" do
      before do
        allow(Rails.application.config.x).to receive(:vapid).and_return(nil)
      end

      it "returns 0 without sending" do
        result = described_class.notify_user(user, title: "Test", body: "Body")
        expect(result).to eq(0)
      end
    end

    context "when VAPID is configured" do
      let(:subscription) { create(:push_subscription, user: user) }

      before do
        allow(Rails.application.config.x).to receive(:vapid).and_return(valid_vapid_config)
      end

      it "attempts to send to all user subscriptions" do
        subscription # ensure exists
        allow_any_instance_of(PushSubscription).to receive(:send_notification).and_return(true)

        result = described_class.notify_user(user, title: "Test", body: "Body")
        expect(result).to eq(1)
      end

      it "handles failed sends gracefully" do
        subscription # ensure exists
        allow_any_instance_of(PushSubscription).to receive(:send_notification).and_return(false)

        result = described_class.notify_user(user, title: "Test", body: "Body")
        expect(result).to eq(0)
      end
    end
  end

  describe ".notify_contact_assigned" do
    let(:subscription) { create(:push_subscription, user: user) }

    before do
      allow(Rails.application.config.x).to receive(:vapid).and_return(valid_vapid_config)
      subscription
      allow_any_instance_of(PushSubscription).to receive(:send_notification).and_return(true)
    end

    it "sends notification with contact details" do
      expected_url = "/sales/workspace?tab=new_contacts&highlight=contact_#{contact.id}"

      expect_any_instance_of(PushSubscription).to receive(:send_notification).with(
        hash_including(title: "📞 Khách hàng mới", url: expected_url)
      )

      described_class.notify_contact_assigned(user, contact)
    end
  end
end
