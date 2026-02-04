# frozen_string_literal: true

require "rails_helper"

# TASK-066: Updated for 3-layer routing system
RSpec.describe SmartRoutingExpandJob, type: :job do
  let(:team) { create(:team) }
  let(:service_type) { create(:service_type, team: team) }
  let(:sale_role) { Role.find_by(code: Role::SALE) || create(:role, code: Role::SALE, dashboard_type: :sale) }
  let(:sale_user) { create(:user, roles: [sale_role], teams: [team]) }
  let(:tongdai_role) { Role.find_by(name: "Tổng Đài") || create(:role, name: "Tổng Đài", code: "call_center") }
  let(:tongdai_user) { create(:user, roles: [tongdai_role]) }

  # Create contact without triggering smart routing callbacks
  let(:contact) do
    Contact.create!(
      name: "Test Contact",
      phone: "0901234567",
      service_type: service_type,
      source: Source.first || create(:source),
      created_by_id: tongdai_user.id,
      status: :new_contact,
      visible_to_user_ids: [sale_user.id],
      routing_layer: 1,
      code: "KH2026-TEST#{rand(10_000)}"
    )
  end

  # Skip smart routing initialization for tests
  before do
    allow_any_instance_of(Contact).to receive(:initialize_smart_routing_and_broadcast)
  end

  describe "#perform with contact_id" do
    context "when contact exists and is unassigned" do
      it "expands visibility via SmartRoutingService" do
        expect(SmartRoutingService).to receive(:expand_visibility_for).with(contact).and_return(true)

        described_class.new.perform(contact.id)
      end
    end

    context "when contact is already assigned" do
      before { contact.update!(assigned_user_id: sale_user.id) }

      it "does not expand visibility" do
        expect(SmartRoutingService).not_to receive(:expand_visibility_for)

        described_class.new.perform(contact.id)
      end

      it "logs skip reason" do
        expect(Rails.logger).to receive(:info).with(/already assigned/)

        described_class.new.perform(contact.id)
      end
    end

    context "when contact does not exist" do
      it "handles gracefully without error" do
        expect { described_class.new.perform(999_999) }.not_to raise_error
      end

      it "logs skip reason" do
        expect(Rails.logger).to receive(:info).with(/not found/)

        described_class.new.perform(999_999)
      end
    end

    context "when contact status is not new_contact" do
      before { contact.update!(status: :potential) }

      it "does not expand visibility" do
        expect(SmartRoutingService).not_to receive(:expand_visibility_for)

        described_class.new.perform(contact.id)
      end
    end
  end

  describe "job cancellation on pick" do
    it "skips expansion when contact has been picked" do
      # Simulate contact being picked between job schedule and execution
      contact.update!(assigned_user_id: sale_user.id, status: :potential)

      expect(SmartRoutingService).not_to receive(:expand_visibility_for)
      described_class.new.perform(contact.id)
    end
  end
end
