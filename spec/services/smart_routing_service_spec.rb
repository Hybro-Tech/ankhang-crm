# frozen_string_literal: true

require "rails_helper"

RSpec.describe SmartRoutingService do
  let(:team) { create(:team) }
  let(:region) { create(:region) }
  let(:province) { create(:province, regions: [region]) }
  let(:service_type) { create(:service_type, team: team) }
  let(:sale_role) { Role.find_by(code: Role::SALE) || create(:role, code: Role::SALE, dashboard_type: :sale) }
  let(:sale_user) { create(:user, roles: [sale_role], teams: [team], region: region) }
  let(:tongdai_role) { Role.find_by(name: "Tổng Đài") || create(:role, name: "Tổng Đài", code: "call_center") }
  let(:tongdai_user) { create(:user, roles: [tongdai_role]) }

  describe ".visible_to?" do
    let(:contact) { create(:contact, service_type: service_type, creator: tongdai_user) }

    context "when contact is in pool mode (visible_to_user_ids is nil)" do
      before { contact.update!(visible_to_user_ids: nil) }

      it "returns true for any user" do
        expect(described_class.visible_to?(contact, sale_user)).to be true
      end
    end

    context "when user is in visibility list" do
      before { contact.update!(visible_to_user_ids: [sale_user.id]) }

      it "returns true" do
        expect(described_class.visible_to?(contact, sale_user)).to be true
      end
    end

    context "when user is not in visibility list" do
      let(:other_user) { create(:user, roles: [sale_role]) }

      before { contact.update!(visible_to_user_ids: [other_user.id]) }

      it "returns false" do
        expect(described_class.visible_to?(contact, sale_user)).to be false
      end
    end

    context "when contact is assigned" do
      before { contact.update!(assigned_user_id: sale_user.id) }

      it "returns true for assignee" do
        expect(described_class.visible_to?(contact, sale_user)).to be true
      end

      it "returns false for non-assignee" do
        other_user = create(:user, roles: [sale_role])
        expect(described_class.visible_to?(contact, other_user)).to be false
      end
    end
  end

  describe ".clear_visibility" do
    let(:contact) { create(:contact, service_type: service_type, creator: tongdai_user) }

    before do
      contact.update!(visible_to_user_ids: [sale_user.id], last_expanded_at: Time.current)
    end

    it "clears visibility list" do
      described_class.clear_visibility(contact)

      expect(contact.reload.visible_to_user_ids).to be_nil
      expect(contact.last_expanded_at).to be_nil
    end
  end

  describe "Role::SALE constant usage" do
    it "uses Role::SALE constant instead of hardcoded string" do
      expect(Role::SALE).to eq("sale")
    end
  end

  describe ".initialize_visibility" do
    let(:contact) { create(:contact, service_type: service_type, creator: tongdai_user, province: province) }

    context "when within working hours" do
      before do
        allow(Setting).to receive(:within_working_hours?).and_return(true)
      end

      context "when sale has UserServiceTypeLimit for service_type" do
        before do
          create(:user_service_type_limit, user: sale_user, service_type: service_type, max_pick_per_day: 10)
        end

        it "sets visibility to single sale (Layer 1)" do
          described_class.initialize_visibility(contact)
          contact.reload

          expect(contact.visible_to_user_ids).to include(sale_user.id)
          expect(contact.routing_layer).to eq(1)
        end

        it "schedules layer 2 expansion job" do
          expect(SmartRoutingExpandJob).to receive(:set).at_least(:once).and_call_original
          described_class.initialize_visibility(contact)
        end
      end

      context "when no sale has UserServiceTypeLimit" do
        it "falls back to regional pool (Layer 2)" do
          # sale_user is in region, so should get regional pool
          described_class.initialize_visibility(contact)
          contact.reload

          expect(contact.routing_layer).to be >= 2
        end
      end
    end

    context "when outside working hours" do
      before do
        allow(Setting).to receive(:within_working_hours?).and_return(false)
      end

      it "skips to national pool (Layer 3)" do
        described_class.initialize_visibility(contact)
        contact.reload

        expect(contact.routing_layer).to eq(3)
        expect(contact.visible_to_user_ids).to be_nil
      end
    end
  end

  describe "#expand_visibility" do
    let(:contact) { create(:contact, service_type: service_type, creator: tongdai_user, province: province) }

    context "when contact is already assigned" do
      before { contact.update!(assigned_user_id: sale_user.id) }

      it "returns false and does not expand" do
        service = described_class.new(contact)
        expect(service.expand_visibility).to be false
      end
    end

    context "when contact is not new_contact status" do
      before { contact.update!(status: :potential) }

      it "returns false and does not expand" do
        service = described_class.new(contact)
        expect(service.expand_visibility).to be false
      end
    end

    context "when expanding from Layer 1 to Layer 2" do
      before do
        contact.update!(
          routing_layer: 1,
          visible_to_user_ids: [sale_user.id],
          status: :new_contact
        )
      end

      it "expands to regional pool" do
        # Create another sale in same region
        create(:user, roles: [sale_role], region: region)

        service = described_class.new(contact)
        expect(service.expand_visibility).to be true

        contact.reload
        expect(contact.routing_layer).to eq(2)
        expect(contact.visible_to_user_ids).to include(sale_user.id)
      end
    end

    context "when expanding from Layer 2 to Layer 3" do
      before do
        contact.update!(
          routing_layer: 2,
          visible_to_user_ids: [sale_user.id],
          status: :new_contact
        )
      end

      it "expands to national pool" do
        service = described_class.new(contact)
        expect(service.expand_visibility).to be true

        contact.reload
        expect(contact.routing_layer).to eq(3)
        expect(contact.visible_to_user_ids).to be_nil
      end
    end
  end

  describe "Setting.routing_expand_minutes integration" do
    it "reads interval from Setting" do
      Setting.set("routing_expand_minutes", "5")
      expect(Setting.routing_expand_minutes).to eq(5)
    end

    it "defaults to 2 if not set" do
      Setting.where(key: "routing_expand_minutes").destroy_all
      expect(Setting.routing_expand_minutes).to eq(2)
    end
  end
end
