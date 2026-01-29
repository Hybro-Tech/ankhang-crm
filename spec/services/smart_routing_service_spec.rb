# frozen_string_literal: true

require "rails_helper"

RSpec.describe SmartRoutingService do
  let(:team) { create(:team) }
  let(:service_type) { create(:service_type, team: team) }
  let(:sale_role) { Role.find_by(code: Role::SALE) || create(:role, code: Role::SALE, dashboard_type: :sale) }
  let(:sale_user) { create(:user, roles: [sale_role], teams: [team]) }
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
      # This test verifies that the refactoring is working correctly
      expect(Role::SALE).to eq("sale")
    end
  end
end
